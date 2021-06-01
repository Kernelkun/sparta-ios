//
//  TappableButton.swift
//  
//
//  Created by Yaroslav Babalich on 21.01.2021.
//

import UIKit
import Then

open class TappableButton: BiggerAreaButton {

    // MARK: - Public properties

    open override var isEnabled: Bool {
        didSet {
            alpha = isEnabled ? 1.0 : 0.5
        }
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        indicatorView.center = center
    }

    //
    // MARK: - Public Accessors

    public func onTap(completion: @escaping TypeClosure<TappableButton>) {
        addTarget(self, action: #selector(onTapEvent(_:)), for: .touchUpInside)
        tapClosure = completion
    }

    public var isLoading: Bool = false {
        didSet {
            if isLoading {
                indicatorView.startAnimating()
                tempTitleStorage = title(for: .normal)
                tempImageStorage = image(for: .normal)
                setTitle(nil, for: .normal)
                setImage(nil, for: .normal)
                imageView?.alpha = 0
            } else if let tempTitleStorage = tempTitleStorage {
                indicatorView.stopAnimating()
                setTitle(tempTitleStorage, for: .normal)
                setImage(tempImageStorage, for: .normal)
                imageView?.alpha = 1
            } else if image(for: .normal) != nil {
                indicatorView.stopAnimating()
                imageView?.alpha = 1
            }
        }
    }

    public func setIsLoading(_ value: Bool, animated: Bool) {
        UIView.animate(withDuration: animated ? 0.3 : 0) {
            self.isLoading = value
        }
    }

    public func showTemporaryText(_ text: String, for time: TimeInterval = 0.5) {

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
    private var tempImageStorage: UIImage?

    private lazy var indicatorView = UIActivityIndicatorView().then { view in

        view.color = titleColor(for: .normal)
        view.hidesWhenStopped = true
        view.stopAnimating()

        addSubview(view)
    }

    @objc
    private func onTapEvent(_ sender: UIButton) {
        tapClosure?(self)
    }
}
