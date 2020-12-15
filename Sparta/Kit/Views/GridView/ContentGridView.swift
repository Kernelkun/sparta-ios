//
//  ContentGridView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 15.12.2020.
//

import UIKit

class ContentGridView: UIView {

    // MARK: - UI

    var collectionView: UICollectionView!
    var tableView: UITableView!

    private var contentView: UIView!
    private var collectionGridLayout: GridLayout!

    // MARK: - Private properties

    // MARK: - Initializers

    init() {
        super.init(frame: .zero)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public methods

    func reloadData() {
        collectionGridLayout.invalidateLayout()
        collectionView.reloadData()
        tableView.reloadData()
    }

    func fixScroll() {
        tableView.contentOffset.y = collectionView.contentOffset.y
    }

    // MARK: - Private methods

    private func setupUI() {
        contentView = UIView().then { view in

            view.backgroundColor = UIBlenderConstants.mainBackgroundColor

            addSubview(view) {
                $0.left.right.bottom.equalToSuperview()
                $0.top.equalToSuperview()
            }
        }

        tableView = UITableView().then { tableView in

            tableView.tableFooterView = UIView(frame: .zero)
            tableView.separatorStyle = .none
            tableView.showsVerticalScrollIndicator = false
            tableView.showsHorizontalScrollIndicator = false
            tableView.automaticallyAdjustsScrollIndicatorInsets = false
            tableView.bounces = false

            tableView.register(BlenderInfoTableViewCell.self)
            tableView.register(BlenderGradeTableViewCell.self)

            let cell = BlenderGradeTableViewCell()
            cell.apply(title: "Grade", for: IndexPath(row: 0, section: 0))
            tableView.tableHeaderView = cell
            tableView.tableHeaderView?.frame.size.height = 50


            contentView.addSubview(tableView) {
                $0.top.equalToSuperview()
                $0.left.equalToSuperview().offset(18)
                $0.bottom.equalToSuperview()
                $0.width.equalTo(130)
            }
        }

        collectionGridLayout = GridLayout()
        collectionGridLayout.cellWidths = [ 100, 100, 100, 100, 100, 100 ]
        collectionGridLayout.cellHeights = [ 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50 ]

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionGridLayout).then { collectionView in

            collectionView.isDirectionalLockEnabled = true
            collectionView.showsVerticalScrollIndicator = true
            collectionView.showsHorizontalScrollIndicator = true
            collectionView.automaticallyAdjustsScrollIndicatorInsets = false
            collectionView.bounces = false

            collectionView.register(BlenderInfoCollectionViewCell.self)
            collectionView.register(BlenderGradeCollectionViewCell.self)

            contentView.addSubview(collectionView) {
                $0.top.equalTo(tableView)
                $0.right.bottom.equalToSuperview()
                $0.left.equalTo(tableView.snp.right)
            }
        }
    }
}
