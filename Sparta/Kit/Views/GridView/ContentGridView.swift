//
//  ContentGridView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 15.12.2020.
//

import UIKit

protocol ContentGridViewDataSource: AnyObject {
    func contentGridViewScrollableGradeWidth() -> CGFloat
    func contentGridViewNonScrollableGradeWidth() -> CGFloat
    func contentGridViewCollectionNumberOfRows() -> Int
}

class ContentGridView: UIView {

    // MARK: - UI

    var gradesCollectionGridLayout: GridLayout!
    var gradesCollectionView: UICollectionView!

    var contentCollectionGridLayout: GridLayout!
    var contentCollectionView: UICollectionView!

    private var contentView: UIView!

    // MARK: - Private properties

    private let dataSource: ContentGridViewDataSource

    // MARK: - Initializers

    init(dataSource: ContentGridViewDataSource) {
        self.dataSource = dataSource
        
        super.init(frame: .zero)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public methods

    func reloadData() {
        gradesCollectionGridLayout.invalidateCache()
        contentCollectionGridLayout.invalidateCache()

        let cellsWidth: [CGFloat] = Array(repeating: 0.0, count: dataSource.contentGridViewCollectionNumberOfRows())
            .compactMap { _ in dataSource.contentGridViewScrollableGradeWidth() }

        contentCollectionGridLayout.cellWidths = cellsWidth

        gradesCollectionView.reloadData()
        contentCollectionView.reloadData()
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

        gradesCollectionGridLayout = GridLayout()
        gradesCollectionGridLayout.cellWidths = [dataSource.contentGridViewNonScrollableGradeWidth()]
        gradesCollectionGridLayout.cellHeights = []

        gradesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: gradesCollectionGridLayout).then { collectionView in

            collectionView.backgroundColor = UIGridViewConstants.mainBackgroundColor
            collectionView.isDirectionalLockEnabled = true
            collectionView.showsVerticalScrollIndicator = false
            collectionView.showsHorizontalScrollIndicator = true
            collectionView.automaticallyAdjustsScrollIndicatorInsets = false
            collectionView.bounces = false

            collectionView.register(ArbsGradeCollectionViewCell.self)
            collectionView.register(LiveCurveGradeTableViewCell.self)
            collectionView.register(BlenderGradeCollectionViewCell.self)

            contentView.addSubview(collectionView) {
                $0.top.equalToSuperview()
                $0.left.equalToSuperview()
                $0.bottom.equalToSuperview()
                $0.width.equalTo(dataSource.contentGridViewNonScrollableGradeWidth())
            }
        }

        let cellsWidth: [CGFloat] = Array(repeating: 0.0, count: dataSource.contentGridViewCollectionNumberOfRows())
            .compactMap { _ in dataSource.contentGridViewScrollableGradeWidth() }

        contentCollectionGridLayout = GridLayout()
        contentCollectionGridLayout.cellWidths = cellsWidth
        contentCollectionGridLayout.cellHeights = []

        contentCollectionView = UICollectionView(frame: .zero, collectionViewLayout: contentCollectionGridLayout).then { collectionView in

            collectionView.backgroundColor = UIGridViewConstants.mainBackgroundColor
            collectionView.isDirectionalLockEnabled = true
            collectionView.showsVerticalScrollIndicator = false
            collectionView.showsHorizontalScrollIndicator = true
            collectionView.automaticallyAdjustsScrollIndicatorInsets = false
            collectionView.bounces = false

            // live curves
            collectionView.register(LiveCurveInfoCollectionViewCell.self)

            // blender
            collectionView.register(BlenderInfoCollectionViewCell.self)

            // arbs
            collectionView.register(ArbsDeliveryMonthCollectionViewCell.self)
            collectionView.register(ArbsDeliveryPriceCollectionViewCell.self)
            collectionView.register(ArbsPriceDifferentialsCollectionViewCell.self)
            collectionView.register(ArbsUserTgtCollectionViewCell.self)
            collectionView.register(ArbsUserMarginCollectionViewCell.self)
            collectionView.register(ArbsStatusCollectionViewCell.self)

            contentView.addSubview(collectionView) {
                $0.top.equalTo(gradesCollectionView)
                $0.right.bottom.equalToSuperview()
                $0.left.equalTo(gradesCollectionView.snp.right)
            }
        }
    }
}
