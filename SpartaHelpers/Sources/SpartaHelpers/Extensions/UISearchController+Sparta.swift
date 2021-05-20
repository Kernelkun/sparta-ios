//
//  UISearchController+Sparta.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 14.05.2021.
//

import UIKit
import Then

public extension UISearchController {

    func setup(placeholder: String,
               searchBarDelegate: UISearchBarDelegate? = nil,
               searchResultsUpdater: UISearchResultsUpdating? = nil) {

        self.searchResultsUpdater = searchResultsUpdater
        searchBar.delegate = searchBarDelegate
        searchBar.tintColor = .controlTintActive
        obscuresBackgroundDuringPresentation = false

        searchBar.searchTextField.do {

            $0.defaultTextAttributes = [.foregroundColor: UIColor.primaryText]

            $0.attributedPlaceholder = NSAttributedString(
                string: placeholder,
                attributes: [.foregroundColor: UIColor.primaryText]
            )
        }
    }
}
