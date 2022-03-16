//
//  UITextFieldSelector+Configurator.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 01.12.2021.
//

import UIKit

struct UISelectorUIConfigurator {
    let radius: CGFloat
    let backgroundColor: UIColor
    let rightImage: UIImage
    let rightImageSize: CGSize
    let rightImageTintColor: UIColor
    let rightSpace: CGFloat
    let leftSpace: CGFloat
    let placeholderFont: UIFont
    let placeholderColor: UIColor
    let mainFont: UIFont
    let mainColor: UIColor
}

extension UISelectorUIConfigurator {

    static var freightStyle: UISelectorUIConfigurator {
        .init(radius: 8,
              backgroundColor: UIColor.accountFieldBackground,
              rightImage: UIImage(named: "ic_bottom_chevron").required(),
              rightImageSize: CGSize(width: 16, height: 16),
              rightImageTintColor: .primaryText,
              rightSpace: 43,
              leftSpace: 16,
              placeholderFont: .main(weight: .regular, size: 29),
              placeholderColor: .red,
              mainFont: UIFont.main(weight: .regular, size: 15),
              mainColor: .primaryText)
    }

    static var visualisationStyle: UISelectorUIConfigurator {
        .init(radius: 10,
              backgroundColor: .neutral85,
              rightImage: UIImage(systemName: "chevron.down").required(),
              rightImageSize: CGSize(width: 16, height: 16),
              rightImageTintColor: .primaryText,
              rightSpace: 43,
              leftSpace: 16,
              placeholderFont: .main(weight: .regular, size: 29),
              placeholderColor: .red,
              mainFont: UIFont.main(weight: .regular, size: 15),
              mainColor: .primaryText)
    }
}
