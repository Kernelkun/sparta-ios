//
//  LCItemsSelectorViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 13.02.2022.
//

import UIKit
import NetworkingModels
import SpartaHelpers

protocol LCItemsSelectorViewCoordinatorDelegate: AnyObject {
    func lcItemsSelectorViewControllerDidChooseItem(_ viewController: LCItemsSelectorViewController, item: LCWebViewModel.Item)
}

class LCItemsSelectorViewController: BaseTableViewController {

    // MARK: - Public properties

    weak var coordinatorDelegate: LCItemsSelectorViewCoordinatorDelegate?

    // MARK: - Private properties

    private let viewModel: LCItemsSelectorViewModel

    private let searchDelay = DelayObject(delayInterval: 0.5)
    private var searchController: UISearchController!

    // MARK: - Initialiers

    init(viewModel: LCItemsSelectorViewModel) {
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

        // view model

        viewModel.loadData()
    }

    // MARK: - Private methods

    private func setupUI() {
        // search controller

        setupSearchController()

        // table view

        setupTableView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        searchController.isActive = true

        onMainThread(delay: 0.3) {
            self.searchController.searchBar.becomeFirstResponder()
        }
    }

    private func setupSearchController() {
        title = "Portfolio.AddItems.PageTitle".localized

        searchController = UISearchController(searchResultsController: nil).then { vc in
            vc.setup(placeholder: "Search.Title".localized, searchResultsUpdater: self)
            vc.delegate = self
        }

        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController

        setupNavigationBarAppearance(backgroundColor: .barBackground)
    }

    private func setupTableView() {

        tableView.do { tableView in
            tableView.allowsMultipleSelectionDuringEditing = true
            tableView.tableFooterView = UIView()
            tableView.separatorColor = .separator
            tableView.separatorInset = .zero

            tableView.register(LCItemsSelectorHeaderTableView.self)
            tableView.register(LCItemsSelectorTableViewCell.self)
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

extension LCItemsSelectorViewController: UISearchResultsUpdating, UISearchControllerDelegate {

    func updateSearchResults(for searchController: UISearchController) {
        searchDelay.addOperation { [weak self] in
            guard let strongSelf = self else { return }

            let query = searchController.searchBar.text
            strongSelf.viewModel.search(query: query)
        }
    }

    func didPresentSearchController(_ searchController: UISearchController) {
        searchController.searchBar.becomeFirstResponder()
    }
}

extension LCItemsSelectorViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.groups.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.groups[section].items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: LCItemsSelectorTableViewCell = tableView.dequeueReusableCell(for: indexPath)

        let item = viewModel.groups[indexPath.section].items[indexPath.row]
        cell.apply(item: item) { [unowned self] item in
            viewModel.chooseItem(item)
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView: LCItemsSelectorHeaderTableView = tableView.dequeueReusableHeaderFooterView()

        let category = viewModel.groups[section]
        headerView.apply(title: category.title)

        return headerView
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        44
    }
}

extension LCItemsSelectorViewController: LCItemsSelectorViewModelDelegate {

    func didCatchAnError(_ error: String) {
    }

    func didChangeLoadingState(_ isLoading: Bool) {
    }

    func didSuccessFetchList() {
        tableView.reloadData()
    }

    func didSuccessChooseItem(_ item: LCWebViewModel.Item) {
        navigationController?.popViewController(animated: true)
        coordinatorDelegate?.lcItemsSelectorViewControllerDidChooseItem(self, item: item)
    }
}
