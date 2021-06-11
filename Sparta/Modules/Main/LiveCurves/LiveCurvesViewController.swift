//
//  LiveCurvesViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 10.12.2020.
//

import UIKit
import NetworkingModels
import SpartaHelpers

class LiveCurvesViewController: BaseVMViewController<LiveCurvesViewModel> {

    // MARK: - UI

    private var profilesView: ProfilesView<LiveCurveProfileCategory>!
    private var gridView: GridView!
    private var socketsStatusView: SocketsStatusLineView!

    // MARK: - Private properties

    private let pageConfigurator = LiveCurvesPageConfigurator()

    // MARK: - Initializers

    override func loadView() {

        let emptyView = EmptyStateView(titleText: "This portfolio is empty", buttonText: "Add Live Curves")
        emptyView.onButtonTap { [unowned self] in
            self.showPortfolioAddItemsScreen()
        }

        let gridContructor = GridView.GridViewConstructor(rowsCount: viewModel.presentationStyle.rowsCount,
                                                          gradeHeight: 30,
                                                          collectionColumnWidth: 70,
                                                          tableColumnWidth: 130,
                                                          emptyView: emptyView)

        let profilesContructor = ProfilesViewConstructor(addButtonAvailability: true,
                                                         isEditable: false)

        view = UIView().then { view in

            profilesView = ProfilesView(constructor: profilesContructor).then { profilesView in

                profilesView.onChooseProfile { [unowned self] profile in
                    self.viewModel.changeProfile(profile)
                }

                profilesView.onChooseAdd { [unowned self] in
                    navigationController?.pushViewController(LCPortfolioAddViewController(), animated: true)
                }

                view.addSubview(profilesView) {
                    $0.top.equalToSuperview().offset(topBarHeight)
                    $0.left.right.equalToSuperview()
                    $0.height.equalTo(45)
                }
            }

            gridView = GridView(constructor: gridContructor).then { gridView in

                view.addSubview(gridView) {
                    $0.left.right.bottom.equalToSuperview()
                    $0.top.equalTo(profilesView.snp.bottom)
                }
            }
        }
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

        let plusButton = UIBarButtonItemFactory.plusButton { [unowned self] _ in
            self.showPortfolioAddItemsScreen()
        }

        let isActivePeriodButton = viewModel.presentationStyle == .quartersAndYears
        let periodButton = UIBarButtonItemFactory.periodButton(isActive: isActivePeriodButton) { [unowned self] _ in
            self.viewModel.togglePresentationStyle()
        }

        let editButton = UIBarButtonItemFactory.editButton { [unowned self] _ in
            navigationController?.pushViewController(EditPortfolioItemsViewController(), animated: true)
        }

        navigationItem.leftBarButtonItem = UIBarButtonItemFactory.logoButton(title: "Live Curves")
        navigationItem.rightBarButtonItems = [editButton, UIBarButtonItemFactory.fixedSpace(space: 25),
                                              periodButton, UIBarButtonItemFactory.fixedSpace(space: 25),
                                              plusButton]
    }

    private func showPortfolioAddItemsScreen() {
        let viewController = LCPortfolioAddItemViewController(nibName: nil, bundle: nil)
        viewController.onAddItem { [unowned self] in
            pageConfigurator.needToScrollBottom = true
        }
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension LiveCurvesViewController: GridViewDataSource {

    func gradeTitleForInfoCollectionView(at row: Int) -> NSAttributedString? {
        if case let LiveCurvesViewModel.Cell.grade(title) = viewModel.collectionGrades[row] {
            return NSAttributedString(string: title)
        } else { return nil }
    }

    func gradeTitleForGradeCollectionView() -> NSAttributedString? {
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

    func numberOfRowsForGradeCollectionView(in section: Int) -> Int {
        1
    }

    func numberOfRowsForInfoCollectionView(in section: Int) -> Int {
//        viewModel.presentationStyle.rowsCount
        viewModel.collectionGrades.count
    }

    func cellForGradeCollectionView(_ collectionView: UICollectionView, for indexPath: IndexPath) -> UICollectionViewCell {
        let cell: LiveCurveGradeTableViewCell = collectionView.dequeueReusableCell(for: indexPath)

        if case let LiveCurvesViewModel.Cell.grade(title) = viewModel.tableDataSource[indexPath.section] {
            cell.apply(title: title, for: indexPath)
        }

        return cell
    }

    func cellForInfoCollectionView(_ collectionView: UICollectionView, for indexPath: IndexPath) -> UICollectionViewCell {
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

    func didReceiveUpdatesForPresentationStyle() {
        gridView.setInfoRowsCount(viewModel.presentationStyle.rowsCount)
        gridView.reloadInfo()
        setupNavigationUI()
    }

    func didUpdateDataSourceSections(insertions: IndexSet, removals: IndexSet, updates: IndexSet) {
        gridView.updateDataSourceSections(insertions: insertions, removals: removals, updates: updates) { [unowned self] in

            if pageConfigurator.needToScrollBottom {
                gridView.scrollToBottom()
                pageConfigurator.needToScrollBottom = false
            }
        }
    }

    func didReceiveProfilesInfo(profiles: [LiveCurveProfileCategory], selectedProfile: LiveCurveProfileCategory?) {
        profilesView.apply(profiles, selectedProfile: selectedProfile)
    }

    func didChangeConnectionData(title: String, color: UIColor, formattedDate: String?) {
        socketsStatusView.apply(color: color, title: title, formattedDate: formattedDate)
    }
}
