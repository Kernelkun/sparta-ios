//
//  LCPortfolioAddViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 19.05.2021.
//

import UIKit

class LCPortfolioAddViewController: BaseVMViewController<LCPortfolioAddViewModel> {

    // MARK: - Private properties

    private var nameField: RoundedTextField!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    // MARK: - Private methods

    private func setupUI() {

        title = "New portfolio"

        // name field

        _ = setupNameViews(in: view)

        // save button

        _ = BorderedButton(type: .system).then { button in

            button.setTitle("Save", for: .normal)
            button.layer.cornerRadius = 3

            button.onTap { [unowned self] _ in
                self.viewModel.createPortfolio()
            }

            addSubview(button) {
                $0.size.equalTo(CGSize(width: 99, height: 32))
                $0.right.equalToSuperview().inset(24)
                $0.bottom.equalToSuperview().inset(15)
            }
        }
    }

    private func setupNameViews(in contentView: UIView) -> UIView {

        nameField = RoundedTextField().then { field in

            field.icon = nil
            field.textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
            field.placeholder = "Add a portfolio name"

            field.onTextChanged { [unowned self] text in
                self.viewModel.selectedName = text
            }

            contentView.addSubview(field) {
                $0.top.equalToSuperview().offset(topBarHeight + 22)
                $0.left.right.equalToSuperview().inset(24)
                $0.height.equalTo(48)
            }
        }

        return UILabel().then { label in

            label.text = "Name"
            label.textColor = .secondaryText
            label.font = .main(weight: .regular, size: 14)
            label.numberOfLines = 0

            contentView.addSubview(label) {
                $0.top.equalTo(nameField.snp.bottom).offset(3)
                $0.left.equalTo(nameField).offset(3)
            }
        }
    }
}

extension LCPortfolioAddViewController: LCPortfolioAddViewModelDelegate {

    func didCatchAnError(_ error: String) {
        Alert.showOk(title: "Error", message: error, show: self, completion: nil)
    }

    func didChangeLoadingState(_ isLoading: Bool) {
    }

    func didSuccessCreatePortfolio() {
        navigationController?.popViewController(animated: true)
    }
}
