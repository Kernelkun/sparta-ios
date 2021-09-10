//
//  ArbPlaygroundDPSPointView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 06.08.2021.
//

import UIKit
import NetworkingModels

protocol ArbPlaygroundDPSPointViewDelegate: AnyObject {
    func arbPlaygroundDPSPointViewDidChooseMonth(_ view: ArbPlaygroundDPSPointView, newMonth: ArbPlaygroundDPS)
}

class ArbPlaygroundDPSPointView: UIView {

    enum State {
        case inactive
        case active(constructor: ArbPlaygroundPointViewDPSConstructor)
    }

    // MARK: - Public properties

    weak var delegate: ArbPlaygroundDPSPointViewDelegate?

    var state: State = .inactive {
        didSet {
            updateUI()
        }
    }

    // MARK: - Private properties

    private var titleLabel: UILabel!
    private var descriptionLabel: UILabel!
    private var monthSelectorView: UIMonthSelector<ArbPlaygroundDPS>! 

    // MARK: - Initializers

    init() {
        super.init(frame: .zero)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError(#function)
    }

    // MARK: - Private methods

    private func setupUI() {
        monthSelectorView = UIMonthSelector<ArbPlaygroundDPS>().then { view in

            view.onChooseValue { [unowned self] dpsObject in
                self.delegate?.arbPlaygroundDPSPointViewDidChooseMonth(self, newMonth: dpsObject)
            }

            addSubview(view) {
                $0.size.equalTo(CGSize(width: 109, height: 31))
                $0.centerY.equalToSuperview()
                $0.right.equalToSuperview().inset(3)
            }
        }

        titleLabel = UILabel().then { label in

            label.font = .main(weight: .regular, size: 18)
            label.textAlignment = .left
            label.textColor = .plMainText

            addSubview(label) {
                $0.centerY.equalToSuperview()
                $0.left.equalToSuperview()
            }
        }
    }

    private func updateUI() {
        switch state {
        case .inactive:
            titleLabel.text = "-"

        case .active(let constructor):
            titleLabel.text = "Dlvd Price Basis    \(constructor.gradeCode)"
            monthSelectorView.inputValues = constructor.dps
            monthSelectorView.selectedValue = constructor.selectedDPS
        }
    }
}
