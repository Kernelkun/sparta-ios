//
//  ContentSizedTableView.swift
//  
//
//  Created by Yaroslav Babalich on 26.12.2021.
//

import UIKit

open class ContentSizedTableView: UITableView {
    open override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    open override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
    }
}
