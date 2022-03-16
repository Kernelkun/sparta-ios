//
//  UIScrollView+Utilities.swift
//  
//
//  Created by Yaroslav Babalich on 15.02.2022.
//

import UIKit

public extension UIScrollView {

    func scrollView_scrollToBottom(animated: Bool) {
        if self.contentSize.height < self.bounds.size.height { return }

        let bottomOffset = CGPoint(x: 0, y: self.contentSize.height - self.bounds.size.height)
        self.setContentOffset(bottomOffset, animated: animated)
    }
}
