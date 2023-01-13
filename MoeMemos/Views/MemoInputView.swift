//
//  File.swift
//  MoeMemos
//
//  Created by Mudkip on 2022/12/30.
//

import SwiftUI

struct MemoInputView: UIViewControllerRepresentable {
    let memo: Memo?
    
    @EnvironmentObject private var memosViewModel: MemosViewModel

    func makeUIViewController(context: UIViewControllerRepresentableContext<MemoInputView>) -> UINavigationController {
        let navController = UINavigationController(rootViewController: MemoInputViewController(memosViewModel: memosViewModel, memo: memo))
        return navController
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: UIViewControllerRepresentableContext<MemoInputView>) {
        
    }
}
