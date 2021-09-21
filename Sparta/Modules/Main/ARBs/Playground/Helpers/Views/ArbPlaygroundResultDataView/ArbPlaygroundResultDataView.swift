//
//  ArbPlaygroundResultDataView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 10.08.2021.
//

import UIKit
import NetworkingModels

protocol ArbPlaygroundResultDataViewDelegate: AnyObject {
    func arbPlaygroundResultDataViewDidChangeTGTValue(_ view: ArbPlaygroundResultDataView, newValue: Double?)
}

class ArbPlaygroundResultDataView: UIView {

    enum State {
        case inactive
        case active(constructors: [ArbPlaygroundResultViewConstructor])
    }

    // MARK: - Public properties

    weak var delegate: ArbPlaygroundResultDataViewDelegate?

    var state: State {
        didSet {
            updateUI()
        }
    }

    // MARdK: - Private properties

    private var mainStackView: UIStackView!

    // MARK: - Initializers

    init() {
        state = .inactive
        super.init(frame: .zero)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError(#function)
    }

    // MARK: - Public methods

    func becomeTgtFirstResponder() {
        for view in mainStackView.arrangedSubviews where view is ArbPlaygroundResultInputPointView {
            view.becomeFirstResponder()
        }
    }

    // MARK: - Private methods

    private func setupUI() {
        mainStackView = UIStackView().then { stackView in

            stackView.axis = .vertical
            stackView.alignment = .fill
            stackView.spacing = 0
            stackView.distribution = .fill

            addSubview(stackView) {
                $0.edges.equalToSuperview()
            }
        }
    }

    private func updateUI() {
        mainStackView.removeAllSubviews()

        switch state {
        case .inactive:
            print("Inactive state")

        case .active(let constructors):
            constructors.forEach { constructors in
                if let constructor = constructors as? ArbPlaygroundResultMainPointViewConstructor {
                    let pointView = ArbPlaygroundResultMainPointView(constructor: constructor).then { view in

                        view.snp.makeConstraints {
                            $0.height.equalTo(32)
                        }
                    }

                    mainStackView.addArrangedSubview(pointView)
                } else if let constructor = constructors as? ArbPlaygroundResultInputPointViewConstructor {
                    let pointView = ArbPlaygroundResultInputPointView(constructor: constructor).then { view in

                        view.inputField.delegate = self

                        view.snp.makeConstraints {
                            $0.height.equalTo(32)
                        }
                    }

                    mainStackView.addArrangedSubview(pointView)
                }
            }
        }
    }
}

extension ArbPlaygroundResultDataView: RoundedTextFieldDelegate {
    
    func roundedTextFieldDidEndEditing(_ textField: RoundedTextField) {
        let newText = textField.textField.text
        let newValue = newText?.isEmpty ?? true || newText == nil ? nil : newText!.toDouble
        self.delegate?.arbPlaygroundResultDataViewDidChangeTGTValue(self, newValue: newValue)
    }
}
