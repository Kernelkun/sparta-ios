//
//  BlenderViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 02.12.2020.
//

import UIKit

class BlenderViewController: UIViewController {

    // MARK: - UI

    private var collectionGridLayout: GridLayout!
    private var collectionView: UICollectionView!
    private var tableView: UITableView!

    private var popup = PopupViewController()

    // MARK: - Private properties

    private let viewModel = BlenderViewModel()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // UI

        setupUI()
        setupNavigationUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // view model

        viewModel.delegate = self
        viewModel.loadData()
    }

    // MARK: - Private methods

    private func setupUI() {

        view.backgroundColor = UIColor(hex: 0x1D1D1D).withAlphaComponent(0.94)

        let contentView = UIView().then { view in

            view.backgroundColor = UIBlenderConstants.mainBackgroundColor

            addSubview(view) {
                $0.left.right.bottom.equalToSuperview()
                $0.top.equalToSuperview().offset(topBarHeight)
            }
        }

        tableView = UITableView().then { tableView in

            tableView.backgroundColor = .clear
            tableView.tableFooterView = UIView(frame: .zero)
            tableView.separatorStyle = .none
            tableView.showsVerticalScrollIndicator = false
            tableView.showsHorizontalScrollIndicator = false
            tableView.automaticallyAdjustsScrollIndicatorInsets = false
            tableView.contentInset = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 0)

            tableView.register(BlenderInfoTableViewCell.self)
            tableView.register(BlenderGradeTableViewCell.self)

            tableView.delegate = self
            tableView.dataSource = self

            contentView.addSubview(tableView) {
                $0.top.equalToSuperview()
                $0.left.equalToSuperview().offset(18)
                $0.bottom.equalToSuperview()
                $0.width.equalTo(130)
            }
        }

        collectionGridLayout = GridLayout()
        collectionGridLayout.cellWidths = [ 100, 100, 100, 100, 100, 100 ]

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionGridLayout).then { collectionView in

            collectionView.isDirectionalLockEnabled = true
            collectionView.backgroundColor = .clear
            collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            collectionView.showsVerticalScrollIndicator = false
            collectionView.showsHorizontalScrollIndicator = false
            collectionView.automaticallyAdjustsScrollIndicatorInsets = false

            collectionView.dataSource = self
            collectionView.delegate = self

//            collectionView.register(TestCollectionView.self, for: UICollectionView.elementKindSectionHeader)
            collectionView.register(BlenderInfoCollectionViewCell.self)
            collectionView.register(BlenderGradeCollectionViewCell.self)

            contentView.addSubview(collectionView) {
                $0.top.equalTo(tableView)
                $0.right.bottom.equalToSuperview()
                $0.left.equalTo(tableView.snp.right)
            }
        }
    }

    private func setupNavigationUI() {
        navigationItem.title = nil

        navigationItem.leftBarButtonItem = UIBarButtonItemFactory.titleButton(text: "Blender")

        navigationItem.rightBarButtonItem = UIBarButtonItemFactory.seasonalityBlock(onValueChanged: { isOn in
            self.viewModel.isSeasonalityOn = isOn
        })
    }

    private func updateGridHeight() {
        var heights: [CGFloat] = []

        for index in 0..<viewModel.collectionDataSource.count {

            heights.append(viewModel.height(for: index))
        }

        collectionGridLayout.cellHeights = heights
    }
}

extension BlenderViewController: UIScrollViewDelegate, UICollectionViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        var newContentOffset = scrollView.contentOffset
        newContentOffset.x = 0

        if scrollView == tableView {
            collectionView.contentOffset = newContentOffset
        } else if scrollView == collectionView {
            tableView.contentOffset = newContentOffset
        }
    }
}

extension BlenderViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel.collectionDataSource.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.collectionDataSource[section].cells.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cellType = viewModel.collectionDataSource[indexPath.section].cells[indexPath.row]

        switch cellType {
        case .grade(title: let title):

            let cell: BlenderGradeCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)

            cell.apply(title: title, for: indexPath)

            return cell

        case .info(model: let infoModel):

            let cell: BlenderInfoCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)

            cell.apply(infoModel: infoModel, isSeasonalityOn: viewModel.isSeasonalityOn, for: indexPath)

            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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
    }
}

extension BlenderViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.tableDataSource.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cellType = viewModel.tableDataSource[indexPath.section]

        switch cellType {
        case .grade(title: let title):

            let cell: BlenderGradeTableViewCell = tableView.dequeueReusableCell(for: indexPath)

            cell.apply(title: title, for: indexPath)

            return cell

        case .info(model: let infoModel):

            let cell: BlenderInfoTableViewCell = tableView.dequeueReusableCell(for: indexPath)

            cell.apply(infoModel: infoModel, isSeasonalityOn: viewModel.isSeasonalityOn, for: indexPath)

            return cell
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        viewModel.height(for: indexPath.section)
    }
}

extension BlenderViewController: BlenderViewModelDelegate {

    func didUpdateDataSourceSections(insertions: IndexSet, removals: IndexSet, updates: IndexSet, afterSeasonality: Bool) {
        updateGridHeight()

        let updateGroup = DispatchGroup()

        updateGroup.enter()
        tableView.updateSections(insertions: insertions, removals: removals, updates: updates, completion: { _ in
            updateGroup.leave()
        })

        updateGroup.enter()
        collectionView.updateSections(insertions: insertions, removals: removals, updates: updates, completion: { _ in
            updateGroup.leave()
        })

        updateGroup.notify(queue: .main) {

            if afterSeasonality {
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                self.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
            }
        }
    }
}
