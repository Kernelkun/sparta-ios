//
//  LCPresenter+Models.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 05.04.2022.
//

import UIKit

extension LCTradeChartPresenter {
    enum State {
        case minimized
        case fullScreen(orientation: UIInterfaceOrientation)

        var isFullScreen: Bool {
            switch self {
            case .minimized:
                return false

            case .fullScreen:
                return true
            }
        }
    }

    class Configurator {
        let parrentViewController: UIViewController
        let contentView: UIView
        var state: State

        init(parrentViewController: UIViewController, contentView: UIView, state: State) {
            self.parrentViewController = parrentViewController
            self.contentView = contentView
            self.state = state
        }
    }
}
