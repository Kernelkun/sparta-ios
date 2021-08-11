//
//  ArbSearchViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 05.08.2021.
//

import UIKit
import NetworkingModels
import SpartaHelpers

class ArbSearchViewController: BaseTableViewController {

    // MARK: - Public properties

    let viewModel: ArbSearchViewModel

    // MARK: - Private properties

    private weak var coordinatorDelegate: ArbSearchControllerCoordinatorDelegate?

    private let searchDelay = DelayObject(delayInterval: 0.5)

    // MARK: - Initializers

    init(viewModel: ArbSearchViewModel, coordinatorDelegate: ArbSearchControllerCoordinatorDelegate) {
        self.coordinatorDelegate = coordinatorDelegate
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError(#function)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // UI

        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableView.reloadData()
    }

    // MARK: - Private methods

    private func setupUI() {
        // search controller

        setupSearchController()

        // table view

        setupTableView()
    }

    private func setupSearchController() {
    }

    private func setupTableView() {

        tableView.do { tableView in
            tableView.allowsMultipleSelectionDuringEditing = true
            tableView.tableFooterView = UIView()
            tableView.dataSource = self
            tableView.separatorColor = .separator
            tableView.separatorInset = .zero

            tableView.register(LCPortfolioAddItemHeaderTableView.self)
            tableView.register(LCPortfolioAddItemTableViewCell.self)
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
}

extension ArbSearchViewController: UISearchResultsUpdating, UISearchControllerDelegate {

    func updateSearchResults(for searchController: UISearchController) {
        searchDelay.addOperation { [weak self] in
            guard let strongSelf = self else { return }

            let query = searchController.searchBar.text
            strongSelf.viewModel.search(query: query)
        }
    }

    func didPresentSearchController(_ searchController: UISearchController) {
        searchController.searchBar.becomeFirstResponder()
        tableView.reloadData()
    }
}

extension ArbSearchViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.arbs.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: LCPortfolioAddItemTableViewCell = tableView.dequeueReusableCell(for: indexPath)

        let arb = viewModel.arbs[indexPath.row]
        cell.textLabel?.text = arb.grade

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let arb = viewModel.arbs[indexPath.row]
        coordinatorDelegate?.arbSearchControllerDidChoose(arb: arb)
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        44
    }
}

extension ArbSearchViewController: ArbSearchViewModelDelegate {

    func didSuccessLoadArbsList() {
        tableView.reloadData()
    }
}
