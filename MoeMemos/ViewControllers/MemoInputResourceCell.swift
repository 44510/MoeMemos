//
//  MemoInputResourceCell.swift
//  MoeMemos
//
//  Created by Mudkip on 2022/12/30.
//

import UIKit
import PhotosUI

enum MemoInputResourceSection {
    case resource
    case uploading
}

enum MemoInputResourceItem: Hashable {
    case resource(Resource)
    case uploading(PHPickerResult)
}


class MemoInputResourceCell: UICollectionViewCell {
    var resourceButton: UIButton
    
    override init(frame: CGRect) {
        resourceButton = UIButton(type: .custom)
        resourceButton.translatesAutoresizingMaskIntoConstraints = false
        super.init(frame: frame)
        contentView.backgroundColor = .systemRed
        self.contentView.addSubview(resourceButton)
        resourceButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        resourceButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        resourceButton.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        resourceButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        resourceButton.heightAnchor.constraint(equalToConstant: 80).isActive = true
        resourceButton.widthAnchor.constraint(equalToConstant: 80).isActive = true        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(resourceItem: MemoInputResourceItem) {
        
    }
}
