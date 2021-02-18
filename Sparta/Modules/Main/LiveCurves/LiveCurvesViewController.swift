//
//  LiveCurvesViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 10.12.2020.
//

import UIKit

class LiveCurvesViewController: BaseVMViewController<LiveCurvesViewModel> {

    // MARK: - UI

    private var gridView: GridView!
    private var socketsStatusView: SocketsStatusLineView!

    // MARK: - Private properties

    // MARK: - Initializers

    override func loadView() {
        let constructor = GridView.GridViewConstructor(rowsCount: viewModel.monthsCount(),
                                                       gradeHeight: 50,
                                                       collectionColumnWidth: 70,
                                                       tableColumnWidth: 130)

        gridView = GridView(constructor: constructor)
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

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        viewModel.stopLoadData()
    }

    // MARK: - Private methods

    private func setupUI() {

        view.backgroundColor = UIColor(hex: 0x1D1D1D).withAlphaComponent(0.94)

        // grid view

        gridView.dataSource = self
        gridView.apply(topSpace: topBarHeight)
        gridView.applyContentInset(.init(top: 0, left: 0, bottom: 25, right: 0))

        // sockets status view

        socketsStatusView = SocketsStatusLineView().then { view in

            view.backgroundColor = UIGridViewConstants.mainBackgroundColor

            addSubview(view) {
                $0.height.equalTo(25)
                $0.left.right.equalToSuperview()
                $0.bottom.equalToSuperview()
            }
        }
    }

    private func setupNavigationUI() {
        navigationItem.title = nil

        navigationItem.leftBarButtonItem = UIBarButtonItemFactory.logoButton(title: "Live Curves")
    }
}

extension LiveCurvesViewController: GridViewDataSource {

    func gradeTitleForColectionView(at row: Int) -> NSAttributedString? {
        if case let LiveCurvesViewModel.Cell.grade(title) = viewModel.collectionGrades[row] {
            return NSAttributedString(string: title)
        } else { return nil }
    }

    func gradeTitleForTableView() -> NSAttributedString? {
        if case let LiveCurvesViewModel.Cell.grade(title) = viewModel.tableGrade {
            return NSAttributedString(string: title)
        } else { return nil }
    }

    func numberOfSections() -> Int {
        viewModel.tableDataSource.count
    }

    func sectionHeight(_ section: Int) -> CGFloat {
        40
    }

    func numberOfRowsForTableView(in section: Int) -> Int {
        1
    }

    func numberOfRowsForCollectionView(in section: Int) -> Int {
        6
    }

    func cellForTableView(_ tableView: UICollectionView, for indexPath: IndexPath) -> UICollectionViewCell {
        let cell: LiveCurveGradeTableViewCell = tableView.dequeueReusableCell(for: indexPath)

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
        gridView.updateDataSourceSections(insertions: insertions, removals: removals, updates: updates, completion: {
            /*self.gridView.tableView.visibleCells.forEach { cell in
                if let cell = cell as? LiveCurveGradeTableViewCell, let indexPath = self.gridView.tableView.indexPath(for: cell) {
                    if case let LiveCurvesViewModel.Cell.grade(title) = self.viewModel.tableDataSource[indexPath.section] {
                        cell.apply(title: title, for: indexPath)
                    }
                }
            }*/
        })
    }

    func didChangeConnectionData(title: String, color: UIColor, formattedDate: String?) {
        socketsStatusView.apply(color: color, title: title, formattedDate: formattedDate)
    }
}
