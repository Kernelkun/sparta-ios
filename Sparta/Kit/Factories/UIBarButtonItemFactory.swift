//
//  UIBarButtonItemFactory.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 27.11.2020.
//

import UIKit

enum UIBarButtonItemFactory {

    static func backButton(onTap: @escaping TypeClosure<UIButton>) -> UIBarButtonItem {

        let button = TappableButton(type: .system).then { v in

            v.setBackgroundImage(UIImage(named: "ic_back"), for: .normal)
            v.tintColor = .controlTintActive

            v.onTap(completion: onTap)
        }

        return UIBarButtonItem(customView: button)
    }

    static func editNameButton(onTap: @escaping TypeClosure<UIButton>) -> UIBarButtonItem {

        let button = TappableButton(type: .system).then { v in

            v.setBackgroundImage(UIImage(named: "ic_edit_name"), for: .normal)
            v.tintColor = .controlTintActive

            v.onTap(completion: onTap)
        }

        return UIBarButtonItem(customView: button)
    }

    static func deleteButton(onTap: @escaping TypeClosure<UIButton>) -> UIBarButtonItem {

        let button = TappableButton(type: .system).then { v in

            v.setImage(UIImage(named: "ic_delete"), for: .normal)
            v.tintColor = .controlTintActive
            v.frame.size = CGSize(width: 40, height: 16)

            v.onTap(completion: onTap)
        }

        return UIBarButtonItem(customView: button)
    }

    static func closeButton(onTap: @escaping TypeClosure<UIButton>) -> UIBarButtonItem {

        let button = TappableButton(type: .system).then { v in

            v.setBackgroundImage(UIImage(named: "ic_close"), for: .normal)
            v.tintColor = .controlTintActive
            v.frame.size = CGSize(width: 16, height: 16)

            v.onTap(completion: onTap)
        }

        return UIBarButtonItem(customView: button)
    }

    static func titleButton(text: String, onTap: @escaping TypeClosure<UIButton>) -> UIBarButtonItem {

        let button = TappableButton(type: .system).then { v in

            v.setTitle(text.capitalized, for: .normal)
            v.setTitleColor(.controlTintActive, for: .normal)

            v.onTap(completion: onTap)
        }

        return UIBarButtonItem(customView: button)
    }

    static func fixedSpace(space: CGFloat) -> UIBarButtonItem {
        let spaceBarItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        spaceBarItem.width = space
        return spaceBarItem
    }
}
