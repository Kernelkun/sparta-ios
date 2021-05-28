//
//  ReusableView.swift
//  
//
//  Created by Yaroslav Babalich on 21.01.2021.
//

import UIKit

public protocol ReusableView: AnyObject {
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

