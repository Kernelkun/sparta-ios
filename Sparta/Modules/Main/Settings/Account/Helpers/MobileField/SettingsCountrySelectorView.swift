//
//  SettingsCountrySelectorView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 04.01.2022.
//

import UIKit
import PhoneNumberKit

protocol SettingsCountrySelectorViewDelegate: AnyObject {
    func settingsCountrySelectorViewDidChooseCountry(_ view: SettingsCountrySelectorView, country: CMPViewController.Country)
}

class SettingsCountrySelectorView: UIView {

    // MARK: - Public properties

    weak var delegate: SettingsCountrySelectorViewDelegate?

    var country: MobileParser.Country? {
        didSet { updateUI() }
    }

    // MARK: - Private properties

    private let phoneNumberKit: PhoneNumberKit
    private var presentedController: UINavigationController?

    // MARK: - UI

    private var titleLabel: UILabel!

    // MARK: - Initializers

    init(phoneNumberKit: PhoneNumberKit) {
        self.phoneNumberKit = phoneNumberKit
        super.init(frame: .zero)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError(#function)
    }

    // MARK: - Private methods

    private func setupUI() {
        // events

        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapEvent)))

        // general UI

        backgroundColor = UIColor.accountFieldBackground
        layer.cornerRadius = 8

        let chevronImageView = UIImageView().then { imageView in

            imageView.image = UIImage(named: "ic_bottom_chevron")
            imageView.tintColor = .primaryText
            imageView.contentMode = .center

            addSubview(imageView) {
                $0.size.equalTo(12)
                $0.centerY.equalToSuperview()
                $0.right.equalToSuperview().inset(16)
            }
        }

        titleLabel = UILabel().then { label in

            label.textAlignment = .left
            label.font = UIFont.main(weight: .regular, size: 15)

            addSubview(label) {
                $0.top.bottom.equalToSuperview()
                $0.left.equalToSuperview().inset(16)
                $0.right.equalTo(chevronImageView.snp.left).offset(-12)
            }
        }
    }

    private func updateUI() {
        guard let country = country else { return }

        titleLabel.text = country.flag + "  " + country.prefix
    }

    // MARK: - Events

    @objc
    private func onTapEvent() {
        let vc = CMPViewController(phoneNumberKit: phoneNumberKit)
        vc.delegate = self

        if let topVC = UIViewController.topController {
            let nav = UINavigationController(rootViewController: vc)
            topVC.present(nav, animated: true, completion: nil)
            presentedController = nav
        }
    }
}

extension SettingsCountrySelectorView: CMPViewControllerDelegate {

    func cmpViewControllerDidPickCountry(_ country: CMPViewController.Country) {
        delegate?.settingsCountrySelectorViewDidChooseCountry(self, country: country)
        presentedController?.dismiss(animated: true, completion: nil)
    }
}
