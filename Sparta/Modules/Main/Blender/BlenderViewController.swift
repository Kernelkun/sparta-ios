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

    // MARK: - Private properties

    private let viewModel = BlenderViewModel()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // UI

        setupUI()

        // view model

        viewModel.loadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        viewModel.connectToSockets()
    }

    // MARK: - Private methods

    private func setupUI() {

        view.backgroundColor = .mainBackground

        let contentView = UIView().then { view in

            view.backgroundColor = UIBlenderConstants.mainBackgroundColor

            addSubview(view) {
                $0.left.right.bottom.equalToSuperview()
                $0.top.equalToSuperview()
            }
        }

        tableView = UITableView().then { tableView in

            tableView.register(BlenderInfoTableViewCell.self)
            tableView.register(BlenderGradeTableViewCell.self)
            tableView.register(UITableViewCell.self)
            tableView.backgroundColor = .clear
            tableView.tableFooterView = UIView(frame: .zero)
            tableView.separatorStyle = .none
            tableView.showsVerticalScrollIndicator = false
            tableView.rowHeight = UITableView.automaticDimension
            tableView.contentInset = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 0)

            tableView.delegate = self
            tableView.dataSource = self

            contentView.addSubview(tableView) {
                $0.top.equalToSuperview().offset(topBarHeight)
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
            collectionView.register(BlenderInfoCollectionViewCell.self)
            collectionView.register(BlenderGradeCollectionViewCell.self)
            collectionView.dataSource = self
            collectionView.delegate = self

            contentView.addSubview(collectionView) {
                $0.top.equalTo(tableView)
                $0.right.bottom.equalToSuperview()
                $0.left.equalTo(tableView.snp.right)
            }
        }
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

        case .info(title: let title):

            let cell: BlenderInfoCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)

            cell.apply(title: title, for: indexPath)

            return cell
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

        case .info(title: let title):

            let cell: BlenderInfoTableViewCell = tableView.dequeueReusableCell(for: indexPath)

            cell.apply(title: title, for: indexPath)

            return cell
        }
    }
}

extension BlenderViewController: BlenderViewModelDelegate {

    func blenderDidLoadInfo() {
        tableView.reloadData()
    }
}
