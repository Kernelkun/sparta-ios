//
//  ArbsViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 10.12.2020.
//

import UIKit

class ArbsViewController: BaseVMViewController<ArbsViewModel> {

    // MARK: - UI

    private var gridView: GridView!
    private var socketsStatusView: SocketsStatusLineView!

    // MARK: - Private properties

    // MARK: - Initializers

    override func loadView() {
        let constructor = GridView.GridViewConstructor(rowsCount: viewModel.rowsCount(),
                                                       gradeHeight: 50,
                                                       collectionColumnWidth: 65,
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
        navigationItem.backButtonTitle = "Arbs"

        navigationItem.leftBarButtonItem = UIBarButtonItemFactory.logoButton(title: "ARBs")
    }
}

extension ArbsViewController: GridViewDataSource {

    func gradeTitleForColectionView(at row: Int) -> NSAttributedString? {
        if case let ArbsViewModel.Cell.grade(title) = viewModel.collectionGrades[row] {
            return title
        } else { return nil }
    }

    func gradeTitleForTableView() -> NSAttributedString? {
        if case let ArbsViewModel.Cell.grade(title) = viewModel.tableGrade {
            return title
        } else { return nil }
    }

    func numberOfSections() -> Int {
        viewModel.tableDataSource.count
    }

    func sectionHeight(_ section: Int) -> CGFloat {
        150
    }

    func numberOfRowsForTableView(in section: Int) -> Int {
        1
    }

    func numberOfRowsForCollectionView(in section: Int) -> Int {
        viewModel.rowsCount()
    }

    func cellForTableView(_ tableView: UICollectionView, for indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ArbsGradeTableViewCell = tableView.dequeueReusableCell(for: indexPath)

        if case let ArbsViewModel.Cell.title(arb) = viewModel.tableDataSource[indexPath.section] {
            cell.apply(arb: arb)

            cell.onTap { [unowned self] arb in
                self.navigationController?.pushViewController(ArbDetailViewController(arb: arb), animated: true)
            }

            cell.onToggleFavourite { [unowned self] arb in

                self.viewModel.toggleFavourite(arb: arb)
            }
        }

        return cell
    }

    func cellForCollectionView(_ collectionView: UICollectionView, for indexPath: IndexPath) -> UICollectionViewCell {

        let section = viewModel.collectionDataSource[indexPath.section]
        let gradeType = viewModel.collectionGrades[indexPath.row]

        guard case let ArbsViewModel.Cell.info(arb) = section.cells[indexPath.row] else {
            return UICollectionViewCell()
        }

        func fillCell(_ cell: ArbTappableCell) {
            cell.apply(arb: arb)

            cell.onTap { [unowned self] arb in
                self.navigationController?.pushViewController(ArbDetailViewController(arb: arb), animated: true)
            }
        }

        switch gradeType {
        case .status:
            let cell: ArbsStatusCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)

            fillCell(cell)

            return cell

        case .deliveryMonth:
            let cell: ArbsDeliveryMonthCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)

            fillCell(cell)

            return cell

        case .deliveryPrice:
            let cell: ArbsDeliveryPriceCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)

            fillCell(cell)

            return cell

        case .userTgt:
            let cell: ArbsUserTgtCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)

            fillCell(cell)

            return cell

        case .userMargin:
            let cell: ArbsUserMarginCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)

            fillCell(cell)

            return cell

        default:
            return UICollectionViewCell()
        }
    }
}

extension ArbsViewController: ArbsViewModelDelegate {
    func didReceiveUpdatesForGrades() {
        gridView.reloadGrades()
    }

    func didUpdateDataSourceSections(insertions: IndexSet, removals: IndexSet, updates: IndexSet) {
        gridView.updateDataSourceSections(insertions: insertions, removals: removals, updates: updates, completion: {
            /*self.gridView.tableView.visibleCells.forEach { cell in
                if let cell = cell as? LiveCurveGradeTableViewCell, let indexPath = self.gridView.tableView.indexPath(for: cell) {
                    if case let ArbsViewModel.Cell.grade(title) = self.viewModel.tableDataSource[indexPath.section] {
                        cell.apply(title: title, for: indexPath)
                    }
                }
            }*/

//            print("TableViewTest: ContentSize: \(self.gridView.tableView.contentSize)")
//            print("CollectionViewTest: ContentSize: \(self.gridView.collectionView.contentSize)")
        })
    }

    func didChangeConnectionData(title: String, color: UIColor, formattedDate: String?) {
        socketsStatusView.apply(color: color, title: title, formattedDate: formattedDate)
    }

    func didMoveDataSourceSections(fromIndexes: [Int], toIndexes: [Int]) {
        gridView.gradesCollectionView.performBatchUpdates {
            gridView.gradesCollectionView.deleteSections(IndexSet(fromIndexes))
            gridView.gradesCollectionView.insertSections(IndexSet(toIndexes))
        } completion: { _ in
            self.gridView.contentCollectionView.performBatchUpdates {
                self.gridView.contentCollectionView.deleteSections(IndexSet(fromIndexes))
                self.gridView.contentCollectionView.insertSections(IndexSet(toIndexes))
            } completion: { _ in

            }
        }



//        gridView.gradesCollectionView.moveSection(fromIndex, toSection: toIndex)
//        gridView.contentCollectionView.moveSection(fromIndex, toSection: toIndex)
    }
}
