//
//  BlenderViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 02.12.2020.
//

import UIKit

class BlenderViewController: BaseVMViewController<BlenderViewModel> {

    // MARK: - UI

    private var gridView: GridView!
    private var socketsStatusView: SocketsStatusLineView!
    private var popup = PopupViewController()

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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

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

        navigationItem.leftBarButtonItem = UIBarButtonItemFactory.logoButton(title: "Blender")

        navigationItem.rightBarButtonItem = UIBarButtonItemFactory.seasonalityBlock(onValueChanged: { isOn in
            self.viewModel.isSeasonalityOn = isOn
        })
    }

    private func showDescription(for indexPath: IndexPath) {
        guard let monthDetails = viewModel.fetchDescription(for: indexPath) else { return }

        let popupView = BlenderDescriptionPopupView()
        popupView.apply(monthDetailModel: monthDetails)

        popupView.onClose { [unowned self] in
            self.popup.hide()
        }

        popupView.onContentChangeSize { [unowned self] in

            self.popup.contentView?.snp.updateConstraints {
                $0.height.equalTo(popupView.calculatedHeight)
            }
        }

        popup.show(popupView) { make in
            make.center.equalToSuperview()
            make.width.equalTo(210)
            make.height.equalTo(popupView.calculatedHeight)
        }

        // analytics

        viewModel.sendAnalyticsEventPopupShown()
    }
}

extension BlenderViewController: GridViewDataSource {

    func gradeTitleForColectionView(at row: Int) -> NSAttributedString? {
        if case let BlenderViewModel.Cell.grade(title) = viewModel.collectionGrades[row] {
            return NSAttributedString(string: title)
        } else { return nil }
    }

    func gradeTitleForTableView() -> NSAttributedString? {
        if case let BlenderViewModel.Cell.grade(title) = viewModel.tableGrade {
            return NSAttributedString(string: title)
        } else { return nil }
    }

    func numberOfSections() -> Int {
        viewModel.tableDataSource.count
    }

    func sectionHeight(_ section: Int) -> CGFloat {
        viewModel.height(for: section)
    }

    func numberOfRowsForTableView(in section: Int) -> Int {
        1
    }

    func numberOfRowsForCollectionView(in section: Int) -> Int {
        viewModel.monthsCount()
    }

    func cellForTableView(_ tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell {
        let cellType = viewModel.tableDataSource[indexPath.section]

        let cell: BlenderInfoTableViewCell = tableView.dequeueReusableCell(for: indexPath)

        var displayTitle: String = ""

        if case let BlenderViewModel.Cell.grade(title) = cellType {
            displayTitle = title
        }

        cell.apply(title: displayTitle, for: indexPath)
        return cell
    }

    func cellForCollectionView(_ collectionView: UICollectionView, for indexPath: IndexPath) -> UICollectionViewCell {
        let cellType = viewModel.collectionDataSource[indexPath.section].cells[indexPath.item]

        let cell: BlenderInfoCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)

        if case let BlenderViewModel.Cell.info(month) = cellType {
            cell.apply(month: month, isSeasonalityOn: viewModel.isSeasonalityOn, for: indexPath)

            cell.onTap { [unowned self] indexPath in
                self.showDescription(for: indexPath)
            }
        }

        return cell
    }
}

extension BlenderViewController: BlenderViewModelDelegate {

    func didReceiveUpdatesForGrades() {
        gridView.reloadGrades()
    }

    func didUpdateDataSourceSections(insertions: IndexSet, removals: IndexSet, updates: IndexSet, afterSeasonality: Bool) {
        gridView.updateDataSourceSections(insertions: insertions, removals: removals, updates: updates) {
            if afterSeasonality {
                self.gridView.scrollToTop()
            }
        }
    }

    func didChangeConnectionData(title: String, color: UIColor, formattedDate: String?) {
        socketsStatusView.apply(color: color, title: title, formattedDate: formattedDate)
    }
}
