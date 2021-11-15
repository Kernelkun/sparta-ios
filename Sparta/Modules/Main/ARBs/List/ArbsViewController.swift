//
//  ArbsViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 10.12.2020.
//

import UIKit
import NetworkingModels

class ArbsViewController: BaseVMViewController<ArbsViewModel> {

    // MARK: - UI

    private var profilesView: ProfilesView<ArbProfileCategory>!
    private var subProfileView: ProfileDescription!
    private var gridView: GridView!
    private var socketsStatusView: SocketsStatusLineView!

    // MARK: - Private properties

    // MARK: - Initializers

    override func loadView() {

        let gridConstructor = GridView.GridViewConstructor(rowsCount: viewModel.rowsCount(),
                                                           gradeHeight: 50,
                                                           collectionColumnWidth: 65,
                                                           tableColumnWidth: 140,
                                                           emptyView: UIView())

        let profilesContructor = ProfilesViewConstructor(addButtonAvailability: false,
                                                         isEditable: false)

        view = UIView().then { view in

            profilesView = ProfilesView(constructor: profilesContructor).then { profilesView in

                profilesView.onChooseProfile { [unowned self] profile in
                    self.viewModel.changeProfile(profile)
                }

                view.addSubview(profilesView) {
                    $0.top.equalToSuperview().offset(topBarHeight)
                    $0.left.right.equalToSuperview()
                    $0.height.equalTo(45)
                }
            }

            subProfileView = ProfileDescription().then { contentView in

                view.addSubview(contentView) {
                    $0.left.right.equalTo(profilesView)
                    $0.top.equalTo(profilesView.snp.bottom)
                }
            }

            gridView = GridView(constructor: gridConstructor).then { gridView in

                view.addSubview(gridView) {
                    $0.left.right.bottom.equalToSuperview()
                    $0.top.equalTo(subProfileView.snp.bottom)
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
        navigationItem.leftBarButtonItem = UIBarButtonItemFactory.logoButton(title: "MainTabsPage.ARBs.Title".localized)

        let editButton = UIBarButtonItemFactory.editButton { [unowned self] _ in
            navigationController?.pushViewController(ArbsEditPortfolioItemsViewController(), animated: true)
        }

        navigationItem.rightBarButtonItems = [editButton]
    }

    private func navigateToArbDetails(_ arb: Arb) {
        if arb.portfolio.isAra {
            let wireframe = ArbsPlaygroundWireframe(selectedArb: arb)
            self.navigationController?.pushViewController(wireframe.viewController, animated: true)
        } else {
            let wireframe = ArbDetailWireframe(selectedArb: arb)
            self.navigationController?.pushViewController(wireframe.viewController, animated: true)
        }
    }
}

extension ArbsViewController: GridViewDataSource {

    func gradeTitleForInfoCollectionView(at row: Int) -> NSAttributedString? {
        if case let ArbsViewModel.Cell.grade(title) = viewModel.collectionGrades[row] {
            return title
        } else { return nil }
    }

    func gradeTitleForGradeCollectionView() -> NSAttributedString? {
        if case let ArbsViewModel.Cell.grade(title) = viewModel.tableGrade {
            return title
        } else { return nil }
    }

    func numberOfSections() -> Int {
        viewModel.tableDataSource.count
    }

    func sectionHeight(_ section: Int) -> CGFloat {
        if case let ArbsViewModel.Cell.title(arb) = viewModel.tableDataSource[section] {
            return ArbsUIConstants.cellHeight(for: arb.portfolio)
        }

        return ArbsUIConstants.defaultCellHeight
    }

    func numberOfRowsForGradeCollectionView(in section: Int) -> Int {
        1
    }

    func numberOfRowsForInfoCollectionView(in section: Int) -> Int {
        viewModel.rowsCount()
    }

    func cellForGradeCollectionView(_ collectionView: UICollectionView, for indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ArbsGradeCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)

        if case let ArbsViewModel.Cell.title(arb) = viewModel.tableDataSource[indexPath.section] {
            cell.apply(arb: arb)

            cell.onTap { [unowned self] arb in
                guard let newArb = self.viewModel.fetchUpdatedArb(for: arb) else { return }

                self.navigateToArbDetails(newArb)
            }
        }

        return cell
    }

    func cellForInfoCollectionView(_ collectionView: UICollectionView, for indexPath: IndexPath) -> UICollectionViewCell {
        let section = viewModel.collectionDataSource[indexPath.section]
        let gradeType = viewModel.collectionGrades[indexPath.row]

        guard case let ArbsViewModel.Cell.info(arb) = section.cells[indexPath.row] else {
            return UICollectionViewCell()
        }

        func fillCell(_ cell: ArbTappableCell) {
            cell.apply(arb: arb)

            cell.onTap { [unowned self] arb in
                guard let newArb = self.viewModel.fetchUpdatedArb(for: arb) else { return }

                self.navigateToArbDetails(newArb)
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
        gridView.updateDataSourceSections(insertions: insertions, removals: removals, updates: updates)
    }

    func didChangeConnectionData(title: String, color: UIColor, formattedDate: String?) {
        socketsStatusView.apply(color: color, title: title, formattedDate: formattedDate)
    }

    func didReceiveProfilesInfo(profiles: [ArbProfileCategory], selectedProfile: ArbProfileCategory?) {
        profilesView.apply(profiles, selectedProfile: selectedProfile)

        if let descriptionText = selectedProfile?.portfolio.descriptionText?.nullable {
            subProfileView.show(text: descriptionText)
        } else {
            subProfileView.hide()
        }
    }
}
