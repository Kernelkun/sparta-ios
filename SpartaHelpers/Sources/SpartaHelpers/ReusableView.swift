//
//  ReusableView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 27.11.2020.
//

import UIKit

public protocol ReusableView: class {
    static var reuseIdentifier: String { get }
}

public extension ReusableView where Self: UIView {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UITableViewCell: ReusableView {
}

extension UICollectionViewCell: ReusableView {
}

extension UITableViewHeaderFooterView: ReusableView {
}

extension UICollectionReusableView: ReusableView {
}
