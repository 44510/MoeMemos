//
//  MemoInputViewController.swift
//  MoeMemos
//
//  Created by Mudkip on 2022/12/30.
//

import UIKit
import PhotosUI
import Combine

class MemoInputViewController: UIViewController {
    private let memosViewModel: MemosViewModel
    private let memo: Memo?
    private let viewModel = MemoInputViewModel()
    private var subscriptions: Set<AnyCancellable> = []
    
    private var textView: UITextView!
    private var placeholderTextView: UITextView!
    private var containerView: UIStackView!
    private var toolBar: UIToolbar!
    private var tagBarButtonItem: UIBarButtonItem!
    private var resourceCollectionView: UICollectionView!
    private var resourceDataSource: UICollectionViewDiffableDataSource<MemoInputResourceSection, MemoInputResourceItem>!
    
    init(memosViewModel: MemosViewModel, memo: Memo? = nil) {
        self.memosViewModel = memosViewModel
        self.memo = memo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigation()
        setupContainerView()
        setupTextView()
        setupResourceCollectionView()
        setupToolbar()
        setupSubscriptions()
        loadMemo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        textView.becomeFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Task { @MainActor in
            try await memosViewModel.loadTags()
        }
    }
    
    private func setupNavigation() {
        navigationItem.title = "Compose"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(closeButtonTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "paperplane"), style: .done, target: self, action: #selector(saveMemo))
    }
    
    private func setupContainerView() {
        containerView = UIStackView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.axis = .vertical
        containerView.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        containerView.spacing = 10
        containerView.alignment = .fill
        view.addSubview(containerView)
        containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor).isActive = true
    }
    
    private func setupTextView() {
        textView = UITextView()
        textView.font = .preferredFont(forTextStyle: .body)
        textView.delegate = self
        textView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addArrangedSubview(textView)
        
        placeholderTextView = UITextView()
        placeholderTextView.isUserInteractionEnabled = false
        placeholderTextView.font = .preferredFont(forTextStyle: .body)
        placeholderTextView.textColor = .placeholderText
        placeholderTextView.isScrollEnabled = false
        placeholderTextView.translatesAutoresizingMaskIntoConstraints = false
        placeholderTextView.backgroundColor = .clear
        placeholderTextView.text = "Any thoughts..."
        containerView.addSubview(placeholderTextView)
        placeholderTextView.leadingAnchor.constraint(equalTo: textView.leadingAnchor).isActive = true
        placeholderTextView.topAnchor.constraint(equalTo: textView.topAnchor).isActive = true
    }
    
    private func setupResourceCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        resourceCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        resourceCollectionView.translatesAutoresizingMaskIntoConstraints = false
        resourceCollectionView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        resourceCollectionView.register(MemoInputResourceCell.self, forCellWithReuseIdentifier: "MemoInputResourceCell")
        resourceDataSource = UICollectionViewDiffableDataSource(collectionView: resourceCollectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemoInputResourceCell", for: indexPath) as? MemoInputResourceCell
            cell?.setup(resourceItem: itemIdentifier)
            return cell
        })
        resourceCollectionView.dataSource = resourceDataSource
        containerView.addArrangedSubview(resourceCollectionView)
    }
    
    private func setupToolbar() {
        toolBar = UIToolbar()
        toolBar.tintColor = .systemGreen
        tagBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "number"), primaryAction: nil, menu: nil)
        let pictureBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "photo.on.rectangle"), style: .plain, target: self, action: #selector(showPhotoPicker))
        let cameraBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "camera"), style: .plain, target: self, action: #selector(showCamera))
        
        toolBar.items = [self.tagBarButtonItem, pictureBarButtonItem, cameraBarButtonItem]
        toolBar.sizeToFit()
        textView.inputAccessoryView = self.toolBar
    }
    
    private func setupSubscriptions() {
        memosViewModel.$tags.sink { [weak self] tags in
            guard let tagBarButtonItem = self?.tagBarButtonItem else { return }
            let menu = UIMenu(children: tags.map({ tag in
                UIAction(title: tag.name) { _ in
                    self?.selectTag(tag: tag)
                }
            }))
            tagBarButtonItem.menu = menu
        }
        .store(in: &subscriptions)
        
        viewModel.$resourceList.sink { [weak self] resources in
            guard let dataSource = self?.resourceDataSource else { return }
            var snapshot = NSDiffableDataSourceSnapshot<MemoInputResourceSection, MemoInputResourceItem>()
            snapshot.appendSections([.resource, .uploading])
            snapshot.appendItems(resources.map { .resource($0) }, toSection: .resource)
            dataSource.apply(snapshot)
        }
        .store(in: &subscriptions)
    }
    
    private func loadMemo() {
        if let memo = memo {
            textView.text = memo.content
            viewModel.resourceList = memo.resourceList ?? []
        } else {
            
        }
        
        textViewDidChange(textView)
    }
    
    @objc func closeButtonTapped() {
        presentingViewController?.dismiss(animated: true)
    }
    
    @objc func showPhotoPicker() {
        var config = PHPickerConfiguration()
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc func showCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        present(imagePicker, animated: true)
    }
    
    @objc func saveMemo() {
        
    }
    
    private func selectTag(tag: Tag) {
        
    }
}

extension MemoInputViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
    }
}

extension MemoInputViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
    }
}

extension MemoInputViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderTextView.isHidden = !textView.text.isEmpty
    }
}
