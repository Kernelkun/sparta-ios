//
//  UIBarButtonItemFactory.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 27.11.2020.
//

import UIKit
import SpartaHelpers

enum UIBarButtonItemFactory {

    static func backButton(onTap: @escaping TypeClosure<UIButton>) -> UIBarButtonItem {

        let button = TappableButton(type: .system).then { v in

            v.setBackgroundImage(UIImage(named: "ic_back"), for: .normal)
            v.tintColor = .controlTintActive

            v.onTap(completion: onTap)
        }

        return UIBarButtonItem(customView: button)
    }

    static func titleButton(text: String, onTap: @escaping TypeClosure<UIButton>) -> UIBarButtonItem {

        let button = TappableButton(type: .system).then { v in

            v.setTitle(text.capitalized, for: .normal)
            v.setTitleColor(.primaryText, for: .normal)
            v.titleLabel?.font = .main(weight: .regular, size: 18)

            v.onTap(completion: onTap)
        }

        return UIBarButtonItem(customView: button)
    }

    static func seasonalityBlock(onValueChanged: @escaping TypeClosure<Bool>) -> UIBarButtonItem {

        let titleLabel = UILabel().then { label in

            label.font = .main(weight: .regular, size: 12)
            label.textColor = .primaryText
            label.numberOfLines = 1
            label.textAlignment = .left
            label.text = "Seasonality"
        }

        let tappableSwitch = TappableUISwitch().then { view in

            view.onValueChanged(completion: onValueChanged)
        }

        let stackView = UIStackView().then { stackView in

            stackView.addArrangedSubview(titleLabel)
            stackView.addArrangedSubview(tappableSwitch)

            stackView.distribution = .equalSpacing
            stackView.spacing = 7
            stackView.alignment = .center
        }

        return UIBarButtonItem(customView: stackView)
    }

    static func fixedSpace(space: CGFloat) -> UIBarButtonItem {
        let spaceBarItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        spaceBarItem.width = space
        return spaceBarItem
    }
}
