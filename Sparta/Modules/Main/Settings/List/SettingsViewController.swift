//
//  SettingsViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 10.12.2020.
//

import UIKit


class SettingsViewController: BaseVMViewController<SettingsViewModel> {

    // MARK: - UI

    private var tableView: UITableView!

    // MARK: - Private properties

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

        view.backgroundColor = UIColor(hex: 0x1D1D1D).withAlphaComponent(0.94)

        let logoutButton = TappableView().then { view in

            _ = UILabel().then { label in

                label.textAlignment = .left
                label.textColor = .primaryText
                label.numberOfLines = 1
                label.font = .main(weight: .regular, size: 16)
                label.text = "Logout"
                label.isUserInteractionEnabled = true

                view.addSubview(label) {
                    $0.left.equalToSuperview().offset(16)
                    $0.bottom.top.equalToSuperview().inset(11)
                }
            }

            view.onTap { [unowned self] _ in
                self.viewModel.logout()
            }

            view.backgroundColor = UIColor.white.withAlphaComponent(0.04)

            addSubview(view) {
                $0.left.right.equalToSuperview()
                $0.bottom.equalToSuperview().inset(19)
            }
        }

        tableView = UITableView().then { tableView in

            tableView.backgroundColor = .clear
            tableView.tableFooterView = UIView(frame: .zero)
            tableView.separatorStyle = .none
            tableView.showsVerticalScrollIndicator = false
            tableView.showsHorizontalScrollIndicator = false
            tableView.automaticallyAdjustsScrollIndicatorInsets = false
            tableView.rowHeight = UITableView.automaticDimension
            tableView.allowsSelection = true

            tableView.register(SettingsTitledTableViewCell.self)

            tableView.delegate = self
            tableView.dataSource = self

            addSubview(tableView) {
                $0.top.equalToSuperview().offset(topBarHeight + 8)
                $0.left.right.equalToSuperview()
                $0.bottom.equalTo(logoutButton.snp.top)
            }
        }
    }

    private func setupNavigationUI() {
        navigationItem.title = nil

        navigationItem.leftBarButtonItem = UIBarButtonItemFactory.titleButton(text: "Settings")
    }
}

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.sections[section].rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let section = viewModel.sections[indexPath.section]
        let row = section.rows[indexPath.row]

        let cell: SettingsTitledTableViewCell = tableView.dequeueReusableCell(for: indexPath)

        cell.apply(rowName: row)

        cell.onTap { [unowned self] rowName in

            switch rowName {
            case .account:
                navigationController?.pushViewController(AccountSettingsViewController(), animated: true)

            default:
                break
            }
        }

        return cell
    }
}

extension SettingsViewController: SettingsViewModelDelegate {

    func didLoadData() {
        tableView.reloadData()
    }
}
