//
//  UIBarButtonItemFactory.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 27.11.2020.
//

import UIKit
import SpartaHelpers

enum UIBarButtonItemFactory {

    static func logoButton(onTap: TypeClosure<UIButton>? = nil) -> UIBarButtonItem {

        let button = TappableButton(type: .system).then { v in

            v.setBackgroundImage(UIImage(named: "ic_nav_logo"), for: .normal)
            v.tintColor = .controlTintActive

            if let onTap = onTap {
                v.onTap(completion: onTap)
            }
        }

        return UIBarButtonItem(customView: button)
    }

    static func tradeButton(onTap: TypeClosure<UIButton>? = nil) -> UIBarButtonItem {

        let button = TappableButton(type: .system).then { v in

            v.setBackgroundImage(UIImage(named: "ic_trade"), for: .normal)
            v.tintColor = .controlTintActive

            if let onTap = onTap {
                v.onTap(completion: onTap)
            }
        }

        return UIBarButtonItem(customView: button)
    }

    static func backButton(onTap: @escaping TypeClosure<UIButton>) -> UIBarButtonItem {

        let button = TappableButton(type: .system).then { v in

            v.setBackgroundImage(UIImage(named: "ic_back"), for: .normal)
            v.tintColor = .controlTintActive

            v.onTap(completion: onTap)
        }

        return UIBarButtonItem(customView: button)
    }

    static func titleButton(text: String, onTap: TypeClosure<UIButton>? = nil) -> UIBarButtonItem {

        let button = TappableButton(type: .system).then { v in

            v.setTitle(text.capitalized, for: .normal)
            v.setTitleColor(.primaryText, for: .normal)
            v.titleLabel?.font = .main(weight: .regular, size: 18)

            v.onTap { button in onTap?(button) }
        }

        return UIBarButtonItem(customView: button)
    }

    static func seasonalityBlock(onValueChanged: @escaping TypeClosure<Bool>) -> UIBarButtonItem {

        let tappableButton = SeasonalityButton().then { view in

            view.onTap(completion: onValueChanged)
            view.clickableInset = -10

            view.snp.makeConstraints {
                $0.size.equalTo(25)
            }
        }

        return UIBarButtonItem(customView: tappableButton)
    }

    static func fixedSpace(space: CGFloat) -> UIBarButtonItem {
        let spaceBarItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        spaceBarItem.width = space
        return spaceBarItem
    }
}
