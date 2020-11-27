//
//  TappableButton.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 27.11.2020.
//

import UIKit

class TappableButton: BiggerAreaButton {

    // MARK: - Public properties

    override var isEnabled: Bool {
        didSet {
            alpha = isEnabled ? 1.0 : 0.5
        }
    }

    //
    // MARK: - Public Accessors

    func onTap(completion: @escaping TypeClosure<TappableButton>) {
        addTarget(self, action: #selector(onTapEvent(_:)), for: .touchUpInside)
        tapClosure = completion
    }

    var isLoading: Bool = false {
        didSet {
            if isLoading {
                indicatorView.startAnimating()
                tempTitleStorage = title(for: .normal)
                setTitle(nil, for: .normal)
            } else if let tempTitleStorage = tempTitleStorage {
                indicatorView.stopAnimating()
                setTitle(tempTitleStorage, for: .normal)
            } else if image(for: .normal) != nil {
                indicatorView.stopAnimating()
            }
        }
    }

    func setIsLoading(_ value: Bool, animated: Bool) {
        UIView.animate(withDuration: animated ? 0.3 : 0) {
            self.isLoading = value
        }
    }

    func showTemporaryText(_ text: String, for time: TimeInterval = 0.5) {

        isEnabled = false

        tempTitleStorage = title(for: .normal)

        UIView.animate(withDuration: time / 2) {
            self.setTitle(text, for: .normal)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + time) {
            UIView.animate(withDuration: time / 2) {
                self.setTitle(self.tempTitleStorage, for: .normal)

                self.isEnabled = true
            }
        }
    }

    //
    // MARK: - Private Stuff

    private var tapClosure: TypeClosure<TappableButton>?
    private var tempTitleStorage: String?

    private lazy var indicatorView = UIActivityIndicatorView().then { v in

        v.color = titleColor(for: .normal)
        v.hidesWhenStopped = true

        addSubview(v) { $0.center.equalToSuperview() }
    }

    @objc private func onTapEvent(_ sender: UIButton) {
        tapClosure?(self)
    }
}
