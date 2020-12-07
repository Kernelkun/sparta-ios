//
//  BlenderViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 02.12.2020.
//

import UIKit

class BlenderViewController: UIViewController {

    var records: [[String]] = (0 ..< 20).map { row in
        (0 ..< 6).map { column in
            "Row \(row) column \(column)"
        }
    }

    var cellWidths: [CGFloat] = [ 50, 50, 50, 50, 50, 50 ]

    // MARK: - UI

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

        // view model

        viewModel.delegate = self
        viewModel.loadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        viewModel.connectToSockets()
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
            tableView.rowHeight = UITableView.automaticDimension
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

        let layout = GridLayout()
        layout.cellHeight = 44
        layout.cellWidths = cellWidths

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout).then { collectionView in

            collectionView.isDirectionalLockEnabled = true
            collectionView.backgroundColor = .clear
            collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            collectionView.showsVerticalScrollIndicator = false
            collectionView.showsHorizontalScrollIndicator = false
            collectionView.dataSource = self
            collectionView.delegate = self

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

        navigationItem.leftBarButtonItem = UIBarButtonItemFactory.titleButton(text: "Blender", onTap: { _ in
            print("did tap title label")
        })

        navigationItem.rightBarButtonItem = UIBarButtonItemFactory.seasonalityBlock(onValueChanged: { value in
            print("did choose seasonality: \(value)")
        })
    }
}

extension BlenderViewController: UIScrollViewDelegate, UICollectionViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("scrollViewDidScroll")
        if scrollView == tableView {
            var newContentOffset = scrollView.contentOffset
            newContentOffset.x = 0
            collectionView.contentOffset = newContentOffset
        } else if scrollView == collectionView {
            var newContentOffset = scrollView.contentOffset
            newContentOffset.x = 0
            tableView.contentOffset = newContentOffset
        }
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        print("scrollViewWillBeginDragging")
    }
}

extension BlenderViewController: UICollectionViewDataSource {

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

        case .info(let title, let textColor):

            let cell: BlenderInfoCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)

            cell.apply(title: title, textColor: textColor, for: indexPath)

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
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.tableDataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cellType = viewModel.tableDataSource[indexPath.row]

        switch cellType {
        case .grade(title: let title):

            let cell: BlenderGradeTableViewCell = tableView.dequeueReusableCell(for: indexPath)

            cell.apply(title: title, for: indexPath)

            return cell

        case .info(let title, _):

            let cell: BlenderInfoTableViewCell = tableView.dequeueReusableCell(for: indexPath)

            cell.apply(title: title, for: indexPath)

            return cell
        }
    }
}

extension BlenderViewController: BlenderViewModelDelegate {

    func didUpdateTableDataSource(insertions: [IndexPath], removals: [IndexPath], updates: [IndexPath]) {
        tableView.update(insertions: insertions, removals: removals, with: .fade)
    }

    func didUpdateCollectionDataSourceSections(insertions: IndexSet, removals: IndexSet, updates: IndexSet) {
        collectionView.updateSections(insertions: insertions, removals: removals, updates: updates)
    }

    func blenderDidLoadInfo() {
        tableView.reloadData()
        collectionView.reloadData()
    }
}
