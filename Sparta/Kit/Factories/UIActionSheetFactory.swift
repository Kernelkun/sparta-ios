//
//  UIActionSheetFactory.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 31.05.2021.
//

import UIKit
import SpartaHelpers

enum UIActionSheetFactory {

    static func showDeletePortolioConfirmation(in controller: UIViewController, sourceFrame: CGRect? = nil, onDelete: @escaping EmptyClosure) {
        let alertController = UIAlertController(title: nil, message: "Portfolio.RemoveItems.Title".localized, preferredStyle: .actionSheet)

        let deleteAction = UIAlertAction(title: "Delete.Title".localized, style: .destructive, handler: { _ in
            onDelete()
        })

        let cancelAction = UIAlertAction(title: "Cancel.Title".localized, style: .cancel)

        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        alertController.modalPresentationStyle = .popover

        if let popoverPresentationController = alertController.popoverPresentationController,
            let sourceFrame = sourceFrame {
            
            popoverPresentationController.sourceView = controller.view
            popoverPresentationController.sourceRect = sourceFrame
        }

        controller.present(alertController, animated: true, completion: nil)
    }
}
