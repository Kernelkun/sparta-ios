//
//  FreightViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 10.12.2020.
//

import UIKit
import NetworkingModels

class FreightViewController: BaseVMViewController<FreightViewModel> {

    // MARK: - UI

    private var monthField: UITextFieldSelector<PickerIdValued<Date>>!
    private var portField: UITextFieldSelector<PickerIdValued<Int>>!
    private var dischargePortField: UITextFieldSelector<PickerIdValued<Int>>!
    private var vesselTypePortField: UITextFieldSelector<PickerIdValued<Vessel>>!

    private var vesselSpeedField: RoundedTextField!
    private var loadedQuantityField: RoundedTextField!

    // MARK: - Private properties

    private var contentScrollView: UIScrollView!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // UI

        setupUI()
        setupNavigationUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // view model

        viewModel.delegate = self
        viewModel.loadData()
    }

    // MARK: - Private methods

    private func setupUI() {

        contentScrollView = UIScrollView().then { scrollView in

            scrollView.showsVerticalScrollIndicator = false

            addSubview(scrollView) {
                $0.top.equalToSuperview().offset(topBarHeight)
                $0.left.bottom.right.equalToSuperview()
            }
        }

        let scrollViewContent = UIView().then { view in

            view.backgroundColor = .clear

            contentScrollView.addSubview(view) {
                $0.left.top.right.equalToSuperview()
                $0.bottom.lessThanOrEqualToSuperview().priority(.high)
                $0.centerX.equalToSuperview()
            }
        }

        // month views

        let lastMonthView = setupMonthViews(in: scrollViewContent)

        // port views

        let lastPortView = setupPortViews(in: scrollViewContent, topAlignView: lastMonthView)

        // discharge port

        let lastDischargePort = setupDischargePortViews(in: scrollViewContent, topAlignView: lastPortView)

        // vessel type

        let lastVesselType = setupVesselTypeViews(in: scrollViewContent, topAlignView: lastDischargePort)

        // vessel speed

        let lastVesselSpeed = setupVesselSpeedViews(in: scrollViewContent, topAlignView: lastVesselType)

        // loaded quantity

        let lastLoadedQuantity = setupLoadedQuantityViews(in: scrollViewContent, topAlignView: lastVesselSpeed)

        // calculate button

        _ = BorderedButton(type: .system).then { button in

            button.setTitle("Calculate", for: .normal)
            button.layer.cornerRadius = 3

            button.onTap { [unowned self] _ in
                self.viewModel.saveData()
            }

            scrollViewContent.addSubview(button) {
                $0.top.equalTo(lastLoadedQuantity.snp.bottom).offset(12)
                $0.size.equalTo(CGSize(width: 99, height: 32))
                $0.right.equalToSuperview().inset(24)
                $0.bottom.equalToSuperview().inset(15)
            }
        }
    }

    private func setupNavigationUI() {
        navigationItem.title = nil

        navigationItem.leftBarButtonItem = UIBarButtonItemFactory.titleButton(text: "Freight Calculator")
    }

    private func setupMonthViews(in contentView: UIView) -> UIView {

        monthField = UITextFieldSelector().then { view in

            view.onChooseValue { [unowned self] value in
                self.viewModel.selectedMonth = value
                self.viewModel.reloadMainOptions()
            }

            contentView.addSubview(view) {
                $0.top.equalToSuperview().offset(22)
                $0.left.right.equalToSuperview().inset(24)
                $0.height.equalTo(48)
            }
        }

        return UILabel().then { label in

            label.text = "Month"
            label.textColor = .secondaryText
            label.font = .main(weight: .regular, size: 14)
            label.numberOfLines = 0

            contentView.addSubview(label) {
                $0.top.equalTo(monthField.snp.bottom).offset(3)
                $0.left.equalTo(monthField).offset(3)
            }
        }
    }

    private func setupPortViews(in contentView: UIView, topAlignView: UIView) -> UIView {

        portField = UITextFieldSelector().then { view in

            view.onChooseValue { [unowned self] value in
                self.viewModel.selectedFreightPort = value
                self.viewModel.reloadMainOptions()
            }

            contentView.addSubview(view) {
                $0.top.equalTo(topAlignView.snp.bottom).offset(14)
                $0.left.right.equalToSuperview().inset(24)
                $0.height.equalTo(48)
            }
        }

        return UILabel().then { label in

            label.text = "Port"
            label.textColor = .secondaryText
            label.font = .main(weight: .regular, size: 14)
            label.numberOfLines = 0

            contentView.addSubview(label) {
                $0.top.equalTo(portField.snp.bottom).offset(3)
                $0.left.equalTo(portField).offset(3)
            }
        }
    }

    private func setupDischargePortViews(in contentView: UIView, topAlignView: UIView) -> UIView {

        dischargePortField = UITextFieldSelector().then { view in

            view.onChooseValue { [unowned self] value in
                self.viewModel.selectedDischargePort = value
                self.viewModel.reloadMainOptions()
            }

            contentView.addSubview(view) {
                $0.top.equalTo(topAlignView.snp.bottom).offset(14)
                $0.left.right.equalToSuperview().inset(24)
                $0.height.equalTo(48)
            }
        }

        return UILabel().then { label in

            label.text = "Discharge Port"
            label.textColor = .secondaryText
            label.font = .main(weight: .regular, size: 14)
            label.numberOfLines = 0

            contentView.addSubview(label) {
                $0.top.equalTo(dischargePortField.snp.bottom).offset(3)
                $0.left.equalTo(dischargePortField).offset(3)
            }
        }
    }

    private func setupVesselTypeViews(in contentView: UIView, topAlignView: UIView) -> UIView {

        vesselTypePortField = UITextFieldSelector().then { view in

            view.onChooseValue { [unowned self] value in
                self.viewModel.selectedVesselType = value
                self.viewModel.reloadMainOptions()
            }

            contentView.addSubview(view) {
                $0.top.equalTo(topAlignView.snp.bottom).offset(14)
                $0.left.right.equalToSuperview().inset(24)
                $0.height.equalTo(48)
            }
        }

        return UILabel().then { label in

            label.text = "Vessel Type"
            label.textColor = .secondaryText
            label.font = .main(weight: .regular, size: 14)
            label.numberOfLines = 0

            contentView.addSubview(label) {
                $0.top.equalTo(vesselTypePortField.snp.bottom).offset(3)
                $0.left.equalTo(vesselTypePortField).offset(3)
            }
        }
    }

    private func setupVesselSpeedViews(in contentView: UIView, topAlignView: UIView) -> UIView {

        vesselSpeedField = RoundedTextField().then { field in

            field.icon = nil
            field.textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
            field.placeholder = "Vessel speed"

            field.textField.enterType = .numbers(symbolsAfterDot: 2)

            field.onTextChanged { [unowned self] text in
                self.viewModel.selectedVesselSpeed = text
            }

            contentView.addSubview(field) {
                $0.top.equalTo(topAlignView.snp.bottom).offset(14)
                $0.left.right.equalToSuperview().inset(24)
                $0.height.equalTo(48)
            }
        }

        return UILabel().then { label in

            label.text = "Vessel Speed"
            label.textColor = .secondaryText
            label.font = .main(weight: .regular, size: 14)
            label.numberOfLines = 0

            contentView.addSubview(label) {
                $0.top.equalTo(vesselSpeedField.snp.bottom).offset(3)
                $0.left.equalTo(vesselSpeedField).offset(3)
            }
        }
    }

    private func setupLoadedQuantityViews(in contentView: UIView, topAlignView: UIView) -> UIView {

        loadedQuantityField = RoundedTextField().then { field in

            field.icon = nil
            field.textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
            field.placeholder = "Loaded Quantity"

            field.textField.enterType = .numbers(symbolsAfterDot: 2)

            field.onTextChanged { [unowned self] text in
                self.viewModel.selectedLoadedQuantity = text
            }

            contentView.addSubview(field) {
                $0.top.equalTo(topAlignView.snp.bottom).offset(14)
                $0.left.right.equalToSuperview().inset(24)
                $0.height.equalTo(48)
            }
        }

        return UILabel().then { label in

            label.text = "Loaded Quantity"
            label.textColor = .secondaryText
            label.font = .main(weight: .regular, size: 14)
            label.numberOfLines = 0

            contentView.addSubview(label) {
                $0.top.equalTo(loadedQuantityField.snp.bottom).offset(3)
                $0.left.equalTo(loadedQuantityField).offset(3)
            }
        }
    }

    var addedSize: CGSize = .zero

    override func updateUIForKeyboardPresented(_ presented: Bool, frame: CGRect) {
        super.updateUIForKeyboardPresented(presented, frame: frame)

        if presented && addedSize == .zero {
            var oldContentSize = contentScrollView.contentSize
            oldContentSize.height += frame.size.height

            addedSize.height = frame.size.height

            contentScrollView.contentSize = oldContentSize
        } else if !presented && addedSize != .zero {
            var oldContentSize = contentScrollView.contentSize
            oldContentSize.height -= addedSize.height
            addedSize = .zero

            contentScrollView.contentSize = oldContentSize
        }

        if let selectedTextField = view.selectedField {
            let newFrame = selectedTextField.convert(selectedTextField.frame, to: view)

            print("newFrame: \(newFrame), keyboardFrame: \(frame)")

            let maxFieldFrame = newFrame.maxY + 100

            if maxFieldFrame > frame.minY {
                contentScrollView.contentOffset = CGPoint(x: 0, y: maxFieldFrame - frame.minY)
            }
        }
    }
}

extension FreightViewController: FreightViewModelDelegate {

    func didLoadData() {

        // months

        monthField.inputValues = viewModel.months
        monthField.apply(selectedValue: viewModel.selectedMonth, placeholder: "Select month")

        // freight ports

        portField.inputValues = viewModel.freightPorts
        portField.apply(selectedValue: viewModel.selectedFreightPort, placeholder: "Select port")

        // discharge ports

        dischargePortField.inputValues = viewModel.dischargePorts
        dischargePortField.apply(selectedValue: viewModel.selectedDischargePort, placeholder: "Select discharge port")

        // vessel type

        vesselTypePortField.inputValues = viewModel.vesselTypes
        vesselTypePortField.apply(selectedValue: viewModel.selectedVesselType, placeholder: "Select vessel type")

        // speed

        vesselSpeedField.textField.text = viewModel.selectedVesselSpeed

        // loaded quantity

        loadedQuantityField.textField.text = viewModel.selectedLoadedQuantity
    }

    func didReloadMainOptions() {

        // freight ports

        portField.inputValues = viewModel.freightPorts
        portField.apply(selectedValue: viewModel.selectedFreightPort, placeholder: "Select port")

        // discharge ports

        dischargePortField.inputValues = viewModel.dischargePorts
        dischargePortField.apply(selectedValue: viewModel.selectedDischargePort, placeholder: "Select discharge port")

        // vessel type

        vesselTypePortField.inputValues = viewModel.vesselTypes
        vesselTypePortField.apply(selectedValue: viewModel.selectedVesselType, placeholder: "Select vessel type")

        // speed

        vesselSpeedField.textField.text = viewModel.selectedVesselSpeed

        // loaded quantity

        loadedQuantityField.textField.text = viewModel.selectedLoadedQuantity
    }

    func didCatchAnError(_ error: String) {
        Alert.showOk(title: "Error", message: error, show: self, completion: nil)
    }

    func didFinishCalculations(with inputData: FreightCalculator.InputData) {
        self.navigationController?.pushViewController(FreightResultViewController(inputData: inputData), animated: true)
    }
}
