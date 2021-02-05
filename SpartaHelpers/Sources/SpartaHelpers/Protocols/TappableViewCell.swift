//
//  TappableViewCell.swift
//  
//
//  Created by Yaroslav Babalich on 22.01.2021.
//

import UIKit.UIView

public protocol TappableViewCell: UIView {
    var indexPath: IndexPath! { get set }

    func onTap(completion: @escaping TypeClosure<IndexPath>)
}
