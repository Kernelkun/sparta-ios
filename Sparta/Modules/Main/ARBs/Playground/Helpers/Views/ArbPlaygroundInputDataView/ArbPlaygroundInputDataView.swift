//
//  ArbPlaygroundInputDataView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 07.08.2021.
//

import UIKit
import NetworkingModels

protocol ArbPlaygroundInputDataViewDelegate: AnyObject {
    func arbPlaygroundInputDataViewDidChangeValue(_ view: ArbPlaygroundInputDataView, newValue: ArbPlaygroundInputDataView.ObjectValue)
}

class ArbPlaygroundInputDataView: UIView, ArbPlaygroundPointViewDelegate, ArbPlaygroundDPSPointViewDelegate {

    enum State {
        case inactive
        case active(constructor: Constructor)
    }

    enum ObjectValue {
        case blendCost(value: Double)
        case gasNap(value: Double)
        case taArb(value: Double)
        case ew(value: Double) //swiftlint:disable:this identifier_name
        case freight(value: Double)
        case costs(value: Double)
        case spreadMonth(value: ArbPlaygroundDPS)
    }

    // MARK: - Public properties

    weak var delegate: ArbPlaygroundInputDataViewDelegate?

    var state: State {
        didSet {
            updateUI()
        }
    }

    // MARK: - Private properties

    private var blendCostPointView: ArbPlaygroundPointView<Double>!
    private var gasNapPointView: ArbPlaygroundPointView<Double>!
    private var taArbPointView: ArbPlaygroundPointView<Double>!
    private var ewPointView: ArbPlaygroundPointView<Double>!
    private var freightPointView: ArbPlaygroundPointView<Double>!
    private var costsPointView: ArbPlaygroundPointView<Double>!
    private var dpsPointView: ArbPlaygroundDPSPointView!

    // MARK: - Initializers

    init() {
        state = .inactive
        super.init(frame: .zero)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError(#function)
    }

    // MARK: - Private methods

    private func setupUI() {
        blendCostPointView = ArbPlaygroundPointView().then { view in

            view.delegate = self

            view.snp.makeConstraints {
                $0.height.equalTo(54)
            }
        }

        gasNapPointView = ArbPlaygroundPointView().then { view in

            view.delegate = self

            view.snp.makeConstraints {
                $0.height.equalTo(54)
            }
        }

        taArbPointView = ArbPlaygroundPointView().then { view in

            view.delegate = self

            view.snp.makeConstraints {
                $0.height.equalTo(54)
            }
        }

        ewPointView = ArbPlaygroundPointView().then { view in

            view.delegate = self

            view.snp.makeConstraints {
                $0.height.equalTo(54)
            }
        }

        freightPointView = ArbPlaygroundPointView().then { view in

            view.delegate = self

            view.snp.makeConstraints {
                $0.height.equalTo(54)
            }
        }

        costsPointView = ArbPlaygroundPointView().then { view in

            view.delegate = self

            view.snp.makeConstraints {
                $0.height.equalTo(54)
            }
        }

        dpsPointView = ArbPlaygroundDPSPointView().then { view in

            view.delegate = self

            view.snp.makeConstraints {
                $0.height.equalTo(54)
            }
        }

        _ = UIStackView().then { stackView in

            stackView.addArrangedSubview(blendCostPointView)
            stackView.addArrangedSubview(gasNapPointView)
            stackView.addArrangedSubview(taArbPointView)
            stackView.addArrangedSubview(ewPointView)
            stackView.addArrangedSubview(freightPointView)
            stackView.addArrangedSubview(costsPointView)
            stackView.addArrangedSubview(dpsPointView)

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
        switch state {
        case .inactive:
            blendCostPointView.state = .inactive
            gasNapPointView.state = .inactive
            taArbPointView.state = .inactive
            taArbPointView.isHidden = false
            ewPointView.state = .inactive
            ewPointView.isHidden = true
            freightPointView.state = .inactive
            costsPointView.state = .inactive
            dpsPointView.state = .inactive

        case .active(let constructor):
            blendCostPointView.state = .active(constructor: constructor.blendCostConstructor)
            gasNapPointView.state = .active(constructor: constructor.gasNapConstructor)

            if let taArbConstructor = constructor.taArbConstructor {
                ewPointView.isHidden = true
                taArbPointView.isHidden = false
                taArbPointView.state = .active(constructor: taArbConstructor)
            }

            if let ewConstructor = constructor.ewConstructor {
                taArbPointView.isHidden = true
                ewPointView.isHidden = false
                ewPointView.state = .active(constructor: ewConstructor)
            }

            if constructor.taArbConstructor == nil
                && constructor.ewConstructor == nil {

                taArbPointView.state = .inactive
                taArbPointView.isHidden = false
                ewPointView.isHidden = true
            }

            if let freightConstructor = constructor.freightConstructor {
                freightPointView.state = .active(constructor: freightConstructor)
            } else {
                freightPointView.state = .inactive
            }

            costsPointView.state = .active(constructor: constructor.costsConstructor)
            dpsPointView.state = .active(constructor: constructor.spreadMonthsConstructor)
        }
    }

    // MARK: - ArbPlaygroundPointViewDelegate

    func arbPlaygroundViewDidChangeValue<V>(_ view: ArbPlaygroundPointView<V>, newValue: V) where V: CVarArg, V: Comparable, V: Numeric {
        switch view {
        case blendCostPointView:
            // swiftlint:disable:next force_cast
            delegate?.arbPlaygroundInputDataViewDidChangeValue(self, newValue: .blendCost(value: newValue as! Double))

        case gasNapPointView:
            // swiftlint:disable:next force_cast
            delegate?.arbPlaygroundInputDataViewDidChangeValue(self, newValue: .gasNap(value: newValue as! Double))

        case taArbPointView:
            // swiftlint:disable:next force_cast
            delegate?.arbPlaygroundInputDataViewDidChangeValue(self, newValue: .taArb(value: newValue as! Double))

        case ewPointView:
            // swiftlint:disable:next force_cast
            delegate?.arbPlaygroundInputDataViewDidChangeValue(self, newValue: .ew(value: newValue as! Double))

        case freightPointView:
            // swiftlint:disable:next force_cast
            delegate?.arbPlaygroundInputDataViewDidChangeValue(self, newValue: .freight(value: newValue as! Double))

        case costsPointView:
            // swiftlint:disable:next force_cast
            delegate?.arbPlaygroundInputDataViewDidChangeValue(self, newValue: .costs(value: newValue as! Double))

        default:
            break
        }
    }

    // MARK: - ArbPlaygroundDPSPointViewDelegate

    func arbPlaygroundDPSPointViewDidChooseMonth(_ view: ArbPlaygroundDPSPointView, newMonth: ArbPlaygroundDPS) {
        delegate?.arbPlaygroundInputDataViewDidChangeValue(self, newValue: .spreadMonth(value: newMonth))
    }
}

extension ArbPlaygroundInputDataView {

    struct Constructor {
        let blendCostConstructor: ArbPlaygroundPointViewConstructor<Double>
        let gasNapConstructor: ArbPlaygroundPointViewConstructor<Double>
        let freightConstructor: ArbPlaygroundPointViewConstructor<Double>?
        let taArbConstructor: ArbPlaygroundPointViewConstructor<Double>?
        let ewConstructor: ArbPlaygroundPointViewConstructor<Double>?
        let costsConstructor: ArbPlaygroundPointViewConstructor<Double>
        let spreadMonthsConstructor: ArbPlaygroundPointViewDPSConstructor
    }
}
