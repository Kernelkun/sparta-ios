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
               placeholderColor: UIColor? = nil,
               textColor: UIColor? = nil,
               searchBarDelegate: UISearchBarDelegate? = nil,
               searchResultsUpdater: UISearchResultsUpdating? = nil) {

        self.searchResultsUpdater = searchResultsUpdater
        searchBar.delegate = searchBarDelegate
        searchBar.tintColor = .controlTintActive

        searchBar.searchTextField.do {

            $0.defaultTextAttributes = [.foregroundColor: textColor ?? UIColor.primaryText]

            $0.attributedPlaceholder = NSAttributedString(
                string: placeholder,
                attributes: [.foregroundColor: placeholderColor ?? UIColor.primaryText]
            )
        }
    }

    func setup(placeholder: String) {
        searchBar.placeholder = placeholder
    }
}
