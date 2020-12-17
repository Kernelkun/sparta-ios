//
//  LiveCurvesViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 10.12.2020.
//

import UIKit

class LiveCurvesViewController: BaseVMViewController<LiveCurvesViewModel> {

    // MARK: - UI

    private let gridView: GridView

    // MARK: - Private properties

    // MARK: - Initializers

    init() {
        gridView = GridView()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = gridView
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // UI

        setupUI()
        setupNavigationUI()

        // view model

        viewModel.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // view model

        viewModel.loadData()
    }

    // MARK: - Private methods

    private func setupUI() {

//        view.backgroundColor = UIColor(hex: 0x1D1D1D).withAlphaComponent(0.94)

        gridView.dataSource = self
        gridView.apply(topSpace: topBarHeight)
    }

    private func setupNavigationUI() {
        navigationItem.title = nil

        navigationItem.leftBarButtonItem = UIBarButtonItemFactory.titleButton(text: "Live Curves")
    }
}

extension LiveCurvesViewController: GridViewDelegate, GridViewDataSource {

    func gradeTitleForColectionView(at row: Int) -> String {
        if case let LiveCurvesViewModel.Cell.grade(title) = viewModel.tableGrade {
            return title
        } else { return "" }
    }

    func gradeTitleForTableView(at row: Int) -> String {
        if case let LiveCurvesViewModel.Cell.grade(title) = viewModel.collectionGrades[row] {
            return title
        } else { return "" }
    }

    func numberOfSections() -> Int {
        viewModel.tableDataSource.count
    }

    func sectionHeight(_ section: Int) -> CGFloat {
        50
    }

    func numberOfRowsForTableView(in section: Int) -> Int {
        1
    }

    func numberOfRowsForCollectionView(in section: Int) -> Int {
        6
    }

    func cellForTableView(_ tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell {
        let cell: BlenderGradeTableViewCell = tableView.dequeueReusableCell(for: indexPath)

        if case let LiveCurvesViewModel.Cell.grade(title) = viewModel.tableDataSource[indexPath.section] {
            cell.apply(title: title, for: indexPath)
        }

        return cell
    }

    func cellForCollectionView(_ collectionView: UICollectionView, for indexPath: IndexPath) -> UICollectionViewCell {
        let cell: LiveCurveInfoCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)

        let section = viewModel.collectionDataSource[indexPath.section]
        let row = section.cells[indexPath.row]

        if case let LiveCurvesViewModel.Cell.info(model) = row {
            cell.apply(monthInfo: model, for: indexPath)
        }

        return cell
    }
}

extension LiveCurvesViewController: LiveCurvesViewModelDelegate {
    func didReceiveUpdatesForGrades() {
        gridView.reloadGrades()
    }

    func didUpdateDataSourceSections(insertions: IndexSet, removals: IndexSet, updates: IndexSet) {
        gridView.updateDataSourceSections(insertions: insertions, removals: removals, updates: [])

        gridView.reloadGrades()
    }
}
