//
//  EditPortfolioItemsViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 26.05.2021.
//

import UIKit
import NetworkingModels
import SpartaHelpers

class EditPortfolioItemsViewController: BaseTableVMViewController<EditPortfolioItemsViewModel> {

    // MARK: - Private properties

    private var profilesView: ProfilesView<LiveCurveProfileCategory>!

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
        title = "Edit items"

        setupNavigationBarAppearance(backgroundColor: .barBackground)
    }

    private func setupTableView() {

        tableView.do { tableView in
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

    private func configureHeaderView() -> ProfilesView<LiveCurveProfileCategory> {
        let profilesContructor = ProfilesViewConstructor(addButtonAvailability: false)

        return ProfilesView(constructor: profilesContructor).then { profilesView in

            profilesView.onChooseProfile { [unowned self] profile in
                self.viewModel.changeProfile(profile)
            }

            profilesView.onChooseAdd { [unowned self] in
                navigationController?.pushViewController(LCPortfolioAddViewController(), animated: true)
            }
        }
    }
}

extension EditPortfolioItemsViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.selectedProfile.liveCurves.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: EditPortfolioItemsTableViewCell = tableView.dequeueReusableCell(for: indexPath)

        let liveCurve = viewModel.selectedProfile.liveCurves[indexPath.row]

        cell.textLabel?.text = liveCurve.shortName

        return cell
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .delete
    }

    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        false
    }

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        true
    }

    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movingItem = viewModel.selectedProfile.liveCurves[sourceIndexPath.row]

        viewModel.move(item: movingItem, to: destinationIndexPath.row)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }

        let item = viewModel.selectedProfile.liveCurves[indexPath.row]
        viewModel.delete(item: item)
    }

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

extension EditPortfolioItemsViewController: EditPortfolioItemsViewModelDelegate {

    func didUpdateDataSource(insertions: [IndexPath], removals: [IndexPath], updates: [IndexPath]) {
        tableView.update(insertions: insertions, removals: removals, with: .automatic)
    }

    func didCatchAnError(_ error: String) {
    }

    func didChangeLoadingState(_ isLoading: Bool) {
    }

    func didReceiveProfilesInfo(profiles: [LiveCurveProfileCategory], selectedProfile: LiveCurveProfileCategory?) {
        profilesView.apply(profiles, selectedProfile: selectedProfile)
        tableView.reloadData()
    }

    func didSuccessAddItem() {
        navigationController?.popViewController(animated: true)
    }
}
