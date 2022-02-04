//
//  BlenderViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 02.12.2020.
//

import UIKit
import NetworkingModels

class BlenderViewController: BaseVMViewController<BlenderViewModel> {

    // MARK: - UI

    private var profilesView: ProfilesView<BlenderProfileCategory>!
    private var gridView: GridView!
    private var socketsStatusView: SocketsStatusLineView!
    private var popup = PopupViewController()

    // MARK: - Initializers

    override func loadView() {
        let gridContructor = GridView.GridViewConstructor(rowsCount: viewModel.monthsCount(),
                                                          gradeHeight: 50,
                                                          collectionColumnWidth: 70,
                                                          tableColumnWidth: 160,
                                                          emptyView: UIView())

        let profilesContructor = ProfilesViewConstructor(addButtonAvailability: false,
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

        navigationItem.leftBarButtonItem = UIBarButtonItemFactory.logoButton(title: "MainTabsPage.Blender.Title".localized)

        let seasonalityButton = UIBarButtonItemFactory.seasonalityBlock(onValueChanged: { isOn in
            self.viewModel.isSeasonalityOn = isOn
        })

        let editButton = UIBarButtonItemFactory.editButton { [unowned self] _ in
            navigationController?.pushViewController(BlenderEditPortfolioItemsViewController(), animated: true)
        }

        navigationItem.rightBarButtonItems = [editButton, UIBarButtonItemFactory.fixedSpace(space: 25),
                                              seasonalityButton]
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

    func gradeTitleForInfoCollectionView(at row: Int) -> NSAttributedString? {
        guard row < viewModel.collectionGrades.count else { return nil }

        if case let BlenderViewModel.Cell.grade(title) = viewModel.collectionGrades[row] {
            return NSAttributedString(string: title)
        } else { return nil }
    }

    func gradeTitleForGradeCollectionView() -> NSAttributedString? {
        if case let BlenderViewModel.Cell.grade(title) = viewModel.tableGrade {
            return NSAttributedString(string: title)
        } else { return nil }
    }

    func numberOfSections() -> Int {
        viewModel.collectionDataSource.count
    }

    func sectionHeight(_ section: Int) -> CGFloat {
        viewModel.height(for: section)
    }

    func numberOfRowsForGradeCollectionView(in section: Int) -> Int {
        1
    }

    func numberOfRowsForInfoCollectionView(in section: Int) -> Int {
        viewModel.monthsCount()
    }

    func cellForGradeCollectionView(_ collectionView: UICollectionView, for indexPath: IndexPath) -> UICollectionViewCell {
        let cellType = viewModel.tableDataSource[indexPath.section]

        if case let BlenderViewModel.Cell.title(blenderCell) = cellType {
            if blenderCell.isParrent {
                let cell: BlenderGradeCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
                cell.apply(blenderCell: blenderCell)
                return cell
            } else {
                let cell: BlenderGradeNestedCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
                cell.apply(blenderCell: blenderCell)
                return cell
            }
        }

        return UICollectionViewCell()
    }

    func cellForInfoCollectionView(_ collectionView: UICollectionView, for indexPath: IndexPath) -> UICollectionViewCell {
        let cellType = viewModel.collectionDataSource[indexPath.section].cells[indexPath.item]

        let cell: BlenderInfoCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)

        if case let BlenderViewModel.Cell.info(monthCell) = cellType {
            cell.apply(monthCell: monthCell, isSeasonalityOn: viewModel.isSeasonalityOn, for: indexPath)

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

    func didReceiveUpdatesForPresentationStyle() {
        gridView.setInfoRowsCount(viewModel.monthsCount())
    }

    func didUpdateDataSourceSections(insertions: IndexSet, removals: IndexSet, updates: IndexSet) {
        gridView.updateDataSourceSections(insertions: insertions, removals: removals, updates: updates)
    }

    func didChangeConnectionData(title: String, color: UIColor, formattedDate: String?) {
        socketsStatusView.apply(color: color, title: title, formattedDate: formattedDate)
    }

    func didReceiveProfilesInfo(profiles: [BlenderProfileCategory], selectedProfile: BlenderProfileCategory?) {
        profilesView.apply(profiles, selectedProfile: selectedProfile)
    }
}
