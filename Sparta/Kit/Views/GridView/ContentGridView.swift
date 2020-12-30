//
//  ContentGridView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 15.12.2020.
//

import UIKit

class ContentGridView: UIView {

    // MARK: - UI

    var collectionGridLayout: GridLayout!
    var collectionView: UICollectionView!
    var tableView: UITableView!

    private var contentView: UIView!

    // MARK: - Public properties

    // MARK: - Private properties

    private let constructor: GridView.GridViewConstructor

    // MARK: - Initializers

    init(constructor: GridView.GridViewConstructor) {
        self.constructor = constructor
        
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

    // MARK: - Private methods

    private func setupUI() {
        contentView = UIView().then { view in

            view.backgroundColor = UIGridViewConstants.mainBackgroundColor

            addSubview(view) {
                $0.left.right.bottom.equalToSuperview()
                $0.top.equalToSuperview()
            }
        }

        tableView = UITableView().then { tableView in

            tableView.backgroundColor = UIGridViewConstants.mainBackgroundColor
            tableView.tableFooterView = UIView(frame: .zero)
            tableView.separatorStyle = .none
            tableView.showsVerticalScrollIndicator = false
            tableView.showsHorizontalScrollIndicator = false
            tableView.automaticallyAdjustsScrollIndicatorInsets = false
            tableView.bounces = false

            tableView.register(LiveCurveGradeTableViewCell.self)
            tableView.register(BlenderInfoTableViewCell.self)

            contentView.addSubview(tableView) {
                $0.top.equalToSuperview()
                $0.left.equalToSuperview()
                $0.bottom.equalToSuperview()
                $0.width.equalTo(constructor.tableColumnWidth)
            }
        }

        let cellsWidth: [CGFloat] = Array(repeating: 0.0, count: constructor.rowsCount)
            .compactMap { _ in constructor.collectionColumnWidth }

        collectionGridLayout = GridLayout()
        collectionGridLayout.cellWidths = cellsWidth
        collectionGridLayout.cellHeights = []

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionGridLayout).then { collectionView in

            collectionView.backgroundColor = UIGridViewConstants.mainBackgroundColor
            collectionView.isDirectionalLockEnabled = true
            collectionView.showsVerticalScrollIndicator = false
            collectionView.showsHorizontalScrollIndicator = true
            collectionView.automaticallyAdjustsScrollIndicatorInsets = false
            collectionView.bounces = false

            collectionView.register(LiveCurveInfoCollectionViewCell.self)
            collectionView.register(BlenderInfoCollectionViewCell.self)

            contentView.addSubview(collectionView) {
                $0.top.equalTo(tableView)
                $0.right.bottom.equalToSuperview()
                $0.left.equalTo(tableView.snp.right)
            }
        }
    }
}
