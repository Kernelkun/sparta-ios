//
//  ContentSizedTableView.swift
//  
//
//  Created by Yaroslav Babalich on 16.02.2022.
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
