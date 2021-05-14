//
//  LCPortfolioAddViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 14.05.2021.
//

import UIKit

class LCPortfolioAddViewController: BaseTableVMViewController<LCPortfolioAddViewModel> {

    // MARK: - Private properties

    private var searchController: UISearchController!

    // MARK: - Initializers

    init() {
        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .overFullScreen
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // UI

        setupUI()

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

    private func setupSearchController() {
        guard navigationItem.searchController == nil else { return }

        searchController = UISearchController(searchResultsController: nil).then { vc in
            vc.setup(placeholder: "Search", searchResultsUpdater: self)
        }

        searchController.isActive = true

        navigationItem.searchController = searchController
    }

    private func setupTableView() {

        tableView.do { v in
            v.allowsMultipleSelectionDuringEditing = true
            v.tableFooterView = UIView()
            v.dataSource = self
            v.register(LCPortfolioAddTableViewCell.self)
        }
    }
}

extension LCPortfolioAddViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        /*searchDelay.addOperation { [weak self] in
            guard let strongSelf = self else { return }

            let query = searchController.searchBar.text
            strongSelf.viewModel.searchRooms(request: query)
        }*/
    }
}

extension LCPortfolioAddViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.categories.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.categories[section].items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: LCPortfolioAddTableViewCell = tableView.dequeueReusableCell(for: indexPath)

        let item = viewModel.categories[indexPath.section].items[indexPath.row]

        cell.textLabel?.text = item.title

        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let category = viewModel.categories[section]
        return category.title
    }
}

extension LCPortfolioAddViewController: LCPortfolioAddViewModelDelegate {

    func didCatchAnError(_ error: String) {
        
    }

    func didChangeLoadingState(_ isLoading: Bool) {

    }

    func didSuccessFetchList() {
        tableView.reloadData()
    }
}
