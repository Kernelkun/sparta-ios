//
//  FloatyMenuViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 11.02.2022.
//

import UIKit
import SpartaHelpers

class FloatyMenuViewController: UIViewController {

    // MARK: - Private properties

    private let tabs: [TabMenuItem]
    private let menuItemsCount: Int

    private var _onHideClosure: EmptyClosure?
    private var _onChooseClosure: TypeClosure<TabMenuItem>?

    // MARK: - UI

    private var backgroundContentView: UIView?
    private var menuView: FloatyMenuView!

    // MARK: - Initializers

    init(tabs: [TabMenuItem], menuItemsCount: Int) {
        self.tabs = tabs
        self.menuItemsCount = menuItemsCount
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError(#function)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    // MARK: - Public methods

    func onChoose(completion: @escaping TypeClosure<TabMenuItem>) {
        _onChooseClosure = completion
    }

    func onHide(completion: @escaping EmptyClosure) {
        _onHideClosure = completion
    }

    // MARK: - Private methods

    private func setupUI() {
        view.backgroundColor = .clear

        backgroundContentView = UIView().then { view in

            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backgroundTapEvent)))

            addSubview(view) {
                $0.edges.equalToSuperview()
            }
        }

        let alignView = UIView().then { view in

            view.backgroundColor = .clear

            addSubview(view) {
                let screenWidth = UIScreen.main.bounds.width
                let viewWidth = screenWidth / Double(menuItemsCount)

                $0.right.bottom.equalToSuperview()
                $0.width.equalTo(viewWidth)
                $0.height.equalTo(1)
            }
        }

        menuView = FloatyMenuView().then { view in

            view.alpha = 0
            view.apply(items: tabs)
            view.onChoose { [unowned self] menuItem in
                self._onChooseClosure?(menuItem)
            }

            addSubview(view) {
                $0.centerX.equalTo(alignView).offset(-6)
                $0.bottom.equalToSuperview().inset(14)
            }
        }

        UIView.animate(withDuration: 0.2) {
            self.menuView.alpha = 1.0
        }
    }

    // MARK: - Events

    @objc
    private func backgroundTapEvent() {
        _onHideClosure?()

        UIView.animate(withDuration: 0.2) {
            self.menuView.alpha = 0.0
        }
    }
}
