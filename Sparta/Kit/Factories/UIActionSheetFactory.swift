//
//  UIActionSheetFactory.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 31.05.2021.
//

import UIKit
import SpartaHelpers

enum UIActionSheetFactory {

    static func showDeletePortolioConfirmation(in controller: UIViewController, onDelete: @escaping EmptyClosure) {
        let alertController = UIAlertController(title: nil, message: "Confirm portfolio removing", preferredStyle: .actionSheet)

        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            onDelete()
        })

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)

        controller.present(alertController, animated: true, completion: nil)
    }
}
