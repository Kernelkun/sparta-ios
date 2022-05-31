//
//  ArbsEditPortfolioItemsViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 12.11.2021.
//

import UIKit
import NetworkingModels
import SpartaHelpers

class ArbsEditPortfolioItemsViewController: BaseTableVMViewController<ArbsEditPortfolioItemsViewModel> {

    // MARK: - Private properties

    private var profilesView: ProfilesView<ArbProfileCategory>!

    // MARK: - Initializers

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // UI

        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableView.isEditing = true

        // view model

        viewModel.loadData()
    }

    // MARK: - Private methods

    private func setupUI() {
        // search controller

        setupNavigationUI()

        // table view

        setupTableView()

        // profiles views

        profilesView = configureHeaderView()
    }

    private func setupNavigationUI() {
        title = "Portfolio.EditItems.PageTitle".localized

        setupNavigationBarAppearance(backgroundColor: .barBackground)
    }

    private func setupTableView() {

        tableView.do { tableView in

            if #available(iOS 15, *) {
                tableView.sectionHeaderTopPadding = 0
            }

            tableView.tableFooterView = UIView()
            tableView.dataSource = self
            tableView.separatorColor = .separator
            tableView.separatorInset = .zero

            tableView.register(EditPortfolioItemsTableViewCell.self)
        }
    }

    private func setupNavigationBarAppearance(backgroundColor: UIColor? = nil) {

        let navigationBarAppearance = UINavigationBarAppearance().then {
            $0.configureWithOpaqueBackground()
            $0.backgroundColor = backgroundColor ?? .barBackground
            $0.titleTextAttributes = [.foregroundColor: UIColor.primaryText]
            $0.shadowColor = backgroundColor
        }

        navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        navigationController?.navigationBar.compactAppearance = navigationBarAppearance
        navigationController?.navigationBar.standardAppearance = navigationBarAppearance

        navigationController?.navigationBar.tintColor = .controlTintActive

        //

        let toolbarAppearance = UIToolbarAppearance().then {

            $0.configureWithOpaqueBackground()
            $0.backgroundColor = backgroundColor ?? .barBackground
        }

        navigationController?.toolbar.compactAppearance = toolbarAppearance
        navigationController?.toolbar.standardAppearance = toolbarAppearance
    }

    private func configureHeaderView() -> ProfilesView<ArbProfileCategory> {
        let profilesContructor = ProfilesViewConstructor(addButtonAvailability: false,
                                                         isEditable: false)

        return ProfilesView(constructor: profilesContructor).then { profilesView in

            profilesView.onChooseProfile { [unowned self] profile in
                self.viewModel.changePortfolio(profile)
            }
        }
    }
}

extension ArbsEditPortfolioItemsViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let selectedPortfolio = viewModel.selectedPortfolio else { return 0 }

        return viewModel.selectedPortfolio.arbs.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: EditPortfolioItemsTableViewCell = tableView.dequeueReusableCell(for: indexPath)

        let arbs = viewModel.selectedPortfolio.arbs[indexPath.row]

        cell.textLabel?.text = arbs.grade + " " + arbs.freight.vessel.type

        return cell
    }

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .none
    }

    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        false
    }

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        true
    }

    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movingItem = viewModel.selectedPortfolio.arbs[sourceIndexPath.row]

        viewModel.move(item: movingItem, to: destinationIndexPath.row)
    }

    /*override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }

        let item = viewModel.selectedPortfolio.arbs[indexPath.row]
        viewModel.delete(item: item)
    }*/

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        profilesView
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        45
    }
}

extension ArbsEditPortfolioItemsViewController: ArbsEditPortfolioItemsViewModelDelegate {

    func didUpdateDataSource(insertions: [IndexPath], removals: [IndexPath], updates: [IndexPath]) {
        tableView.update(insertions: insertions, removals: removals, with: .automatic)
    }

    func didCatchAnError(_ error: String) {
    }

    func didChangeLoadingState(_ isLoading: Bool) {
    }

    func didReceiveProfilesInfo(profiles: [ArbProfileCategory], selectedProfile: ArbProfileCategory?) {
        profilesView.apply(profiles, selectedProfile: selectedProfile)
        tableView.reloadData()
    }

    func didSuccessAddItem() {
        navigationController?.popViewController(animated: true)
    }
}
