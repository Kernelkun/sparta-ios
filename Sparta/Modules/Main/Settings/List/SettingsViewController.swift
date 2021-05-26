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

        let logoutButton = LineButtonView(title: "Logout").then { view in

            view.onTap { [unowned self] in
                self.viewModel.logout()
            }

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
        navigationItem.backButtonTitle = "Settings"

        navigationItem.leftBarButtonItem = UIBarButtonItemFactory.logoButton(title: "Settings")
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
