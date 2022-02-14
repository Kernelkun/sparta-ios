//
//  DateSelectorViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 13.02.2022.
//

import UIKit
import PanModal

class DateSelectorViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
    }
}

extension DateSelectorViewController: PanModalPresentable {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    var panScrollable: UIScrollView? {
        return nil
    }

    var longFormHeight: PanModalHeight {
        return .maxHeightWithTopInset(200)
    }

    var anchorModalToLongForm: Bool {
        return false
    }

    var dragIndicatorBackgroundColor: UIColor {
        .clear
    }
}
