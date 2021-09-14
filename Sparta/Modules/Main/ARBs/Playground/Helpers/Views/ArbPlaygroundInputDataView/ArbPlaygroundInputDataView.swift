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
    func arbPlaygroundInputDataViewDidTapInputTgt(_ view: ArbPlaygroundInputDataView)
}

class ArbPlaygroundInputDataView: UIView, ArbPlaygroundPointViewDelegate, ArbPlaygroundDPSPointViewDelegate {

    enum State {
        case inactive
        case active(constructor: Constructor)
    }

    enum ObjectValue {
        case blendCost(value: Double, sign: FloatingPointSign)
        case gasNap(value: Double, sign: FloatingPointSign)
        case taArb(value: Double, sign: FloatingPointSign)
        case ew(value: Double, sign: FloatingPointSign) //swiftlint:disable:this identifier_name
        case freight(value: Double, sign: FloatingPointSign)
        case costs(value: Double, sign: FloatingPointSign)
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
    private var freightDPointView: ArbPlaygroundPointView<Double>!
    private var freightIPointView: ArbPlaygroundPointView<Int>!
    private var costsPointView: ArbPlaygroundPointView<Double>!
    private var dpsPointView: ArbPlaygroundDPSPointView!
    private var statusView: ResultAutoStatusView<String>!

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

        statusView = ResultAutoStatusView(id: String.randomPassword).then { view in

            view.backgroundColor = .plResultBlockBackground
            view.onInputTgtTap { [unowned self] in
                self.delegate?.arbPlaygroundInputDataViewDidTapInputTgt(self)
            }

            addSubview(view) {
                $0.top.equalToSuperview().offset(8)
                $0.left.right.equalToSuperview()
                $0.height.equalTo(32)
            }
        }

        blendCostPointView = ArbPlaygroundPointView().then { view in

            view.delegate = self

            view.snp.makeConstraints {
                $0.height.equalTo(48)
            }
        }

        gasNapPointView = ArbPlaygroundPointView().then { view in

            view.delegate = self

            view.snp.makeConstraints {
                $0.height.equalTo(48)
            }
        }

        taArbPointView = ArbPlaygroundPointView().then { view in

            view.delegate = self

            view.snp.makeConstraints {
                $0.height.equalTo(48)
            }
        }

        ewPointView = ArbPlaygroundPointView().then { view in

            view.delegate = self

            view.snp.makeConstraints {
                $0.height.equalTo(48)
            }
        }

        freightDPointView = ArbPlaygroundPointView().then { view in

            view.delegate = self

            view.snp.makeConstraints {
                $0.height.equalTo(48)
            }
        }

        freightIPointView = ArbPlaygroundPointView().then { view in

            view.delegate = self

            view.snp.makeConstraints {
                $0.height.equalTo(48)
            }
        }

        costsPointView = ArbPlaygroundPointView().then { view in

            view.delegate = self

            view.snp.makeConstraints {
                $0.height.equalTo(48)
            }
        }

        dpsPointView = ArbPlaygroundDPSPointView().then { view in

            view.delegate = self

            view.snp.makeConstraints {
                $0.height.equalTo(48)
            }
        }

        _ = UIStackView().then { stackView in

            stackView.addArrangedSubview(blendCostPointView)
            stackView.addArrangedSubview(gasNapPointView)
            stackView.addArrangedSubview(taArbPointView)
            stackView.addArrangedSubview(ewPointView)
            stackView.addArrangedSubview(freightDPointView)
            stackView.addArrangedSubview(freightIPointView)
            stackView.addArrangedSubview(costsPointView)
            stackView.addArrangedSubview(dpsPointView)

            stackView.axis = .vertical
            stackView.alignment = .fill
            stackView.spacing = 0
            stackView.distribution = .fill

            addSubview(stackView) {
                $0.left.equalToSuperview().offset(16)
                $0.right.equalToSuperview().inset(22)
                $0.bottom.equalToSuperview()
                $0.top.equalTo(statusView.snp.bottom)
            }
        }
    }

    private func updateUI() {
        switch state {
        case .inactive:
            isHidden = true
            blendCostPointView.state = .inactive
            gasNapPointView.state = .inactive
            taArbPointView.state = .inactive
            taArbPointView.isHidden = false
            ewPointView.state = .inactive
            ewPointView.isHidden = true
            freightDPointView.state = .inactive
            freightIPointView.isHidden = true
            costsPointView.state = .inactive
            dpsPointView.state = .inactive

        case .active(let constructor):
            isHidden = false
            statusView.apply(position: constructor.statusPosition)
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

            if let freightConstructor = constructor.freightDConstructor {
                freightDPointView.state = .active(constructor: freightConstructor)
            } else {
                freightDPointView.state = .inactive
            }

            if let freightConstructor = constructor.freightIConstructor {
                freightIPointView.isHidden = false
                freightIPointView.state = .active(constructor: freightConstructor)
            } else {
                freightIPointView.isHidden = true
            }

            costsPointView.state = .active(constructor: constructor.costsConstructor)
            dpsPointView.state = .active(constructor: constructor.spreadMonthsConstructor)
        }
    }

    // MARK: - ArbPlaygroundPointViewDelegate

    func arbPlaygroundViewDidChangeValue<V>(_ view: ArbPlaygroundPointView<V>, newValue: V, sign: FloatingPointSign) where V: CVarArg, V: Comparable, V: Numeric {
        switch view {
        case blendCostPointView:
            // swiftlint:disable:next force_cast
            delegate?.arbPlaygroundInputDataViewDidChangeValue(self, newValue: .blendCost(value: newValue as! Double, sign: sign))

        case gasNapPointView:
            // swiftlint:disable:next force_cast
            delegate?.arbPlaygroundInputDataViewDidChangeValue(self, newValue: .gasNap(value: newValue as! Double, sign: sign))

        case taArbPointView:
            // swiftlint:disable:next force_cast
            delegate?.arbPlaygroundInputDataViewDidChangeValue(self, newValue: .taArb(value: newValue as! Double, sign: sign))

        case ewPointView:
            // swiftlint:disable:next force_cast
            delegate?.arbPlaygroundInputDataViewDidChangeValue(self, newValue: .ew(value: newValue as! Double, sign: sign))

        case freightDPointView, freightIPointView:
            var resultValue: Double

            if let newValue = newValue as? Int {
                resultValue = Double(newValue)
            } else {
                resultValue = newValue as! Double // swiftlint:disable:this force_cast
            }

            delegate?.arbPlaygroundInputDataViewDidChangeValue(self, newValue: .freight(value: resultValue, sign: sign))

        case costsPointView:
            // swiftlint:disable:next force_cast
            delegate?.arbPlaygroundInputDataViewDidChangeValue(self, newValue: .costs(value: newValue as! Double, sign: sign))

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
        let statusPosition: ArbMonth.Position?
        let blendCostConstructor: ArbPlaygroundPointViewConstructor<Double>
        let gasNapConstructor: ArbPlaygroundPointViewConstructor<Double>
        let freightDConstructor: ArbPlaygroundPointViewConstructor<Double>?
        let freightIConstructor: ArbPlaygroundPointViewConstructor<Int>?
        let taArbConstructor: ArbPlaygroundPointViewConstructor<Double>?
        let ewConstructor: ArbPlaygroundPointViewConstructor<Double>?
        let costsConstructor: ArbPlaygroundPointViewConstructor<Double>
        let spreadMonthsConstructor: ArbPlaygroundPointViewDPSConstructor
    }
}
