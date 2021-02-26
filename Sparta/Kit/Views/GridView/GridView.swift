//
//  GridView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 15.12.2020.
//

import UIKit
import SpartaHelpers

protocol GridViewDataSource: class {
    func numberOfSections() -> Int
    func sectionHeight(_ section: Int) -> CGFloat
    func numberOfRowsForGradeCollectionView(in section: Int) -> Int
    func numberOfRowsForInfoCollectionView(in section: Int) -> Int
    func cellForGradeCollectionView(_ collectionView: UICollectionView, for indexPath: IndexPath) -> UICollectionViewCell
    func cellForInfoCollectionView(_ collectionView: UICollectionView, for indexPath: IndexPath) -> UICollectionViewCell

    func gradeTitleForGradeCollectionView() -> NSAttributedString?
    func gradeTitleForInfoCollectionView(at row: Int) -> NSAttributedString?
}

class GridView: UIView {

    // MARK: - Public properties

    var gradesCollectionView: UICollectionView {
        contentView.gradesCollectionView
    }

    var contentCollectionView: UICollectionView {
        contentView.contentCollectionView
    }

    weak var dataSource: GridViewDataSource?

    // MARK: - Private properties

    private var gradesView: GradesGridView!
    private var contentView: ContentGridView!

    private let constructor: GridViewConstructor

    // MARK: - Initializers

    init(constructor: GridViewConstructor) {
        self.constructor = constructor

        super.init(frame: .zero)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("GridView")
    }

    // MARK: - Public methods

    func apply(topSpace: CGFloat) {
        gradesView.snp.updateConstraints {
            $0.top.equalToSuperview().offset(topSpace)
        }
    }

    func applyContentInset(_ contentInset: UIEdgeInsets) {

        contentView.contentCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0)
        contentView.gradesCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0)

        contentView.snp.updateConstraints {
            $0.left.equalToSuperview().offset(contentInset.left)
            $0.right.equalToSuperview().inset(contentInset.right)
            $0.bottom.equalToSuperview().inset(contentInset.bottom)
        }
    }

    func reloadGrades() {
        gradesView.reloadData()
    }

    func updateDataSourceSections(insertions: IndexSet, removals: IndexSet, updates: IndexSet, completion: EmptyClosure? = nil) {
        guard !insertions.isEmpty || !removals.isEmpty || !updates.isEmpty else {
            completion?()
            return
        }

        updateGridHeight()

        let updateGroup = DispatchGroup()

        updateGroup.enter()
        contentView.gradesCollectionView.updateSections(insertions: insertions, removals: removals, updates: updates) { _ in
            updateGroup.leave()
        }

        updateGroup.enter()
        contentView.contentCollectionView.updateSections(insertions: insertions, removals: removals, updates: updates) { _ in
            updateGroup.leave()
        }

        updateGroup.notify(queue: .main) {
            completion?()
        }
    }

    func updateGridHeight() {
        var heights: [CGFloat] = []

        for row in 0..<(dataSource?.numberOfSections() ?? 0) {
            heights.append(dataSource?.sectionHeight(row) ?? 0.0)
        }

        contentView.gradesCollectionGridLayout.cellHeights = heights
        contentView.contentCollectionGridLayout.cellHeights = heights
    }

    // MARK: - Private methods

    private func setupUI() {

        backgroundColor = UIGridViewConstants.mainBackgroundColor

        gradesView = GradesGridView(constructor: constructor).then { view in

            view.scrollView.delegate = self
            view.dataSource = self

            addSubview(view) {
                $0.top.equalToSuperview()
                $0.left.equalToSuperview()
                $0.right.equalToSuperview()
                $0.height.equalTo(constructor.gradeHeight)
            }
        }

        contentView = ContentGridView(constructor: constructor).then { view in

            view.gradesCollectionView.delegate = self
            view.gradesCollectionView.dataSource = self

            view.contentCollectionView.delegate = self
            view.contentCollectionView.dataSource = self

            addSubview(view) {
                $0.top.equalTo(gradesView.snp.bottom)
                $0.left.equalToSuperview()
                $0.right.bottom.equalToSuperview()
            }
        }
    }
}

extension GridView: UIScrollViewDelegate, UICollectionViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == contentView.gradesCollectionView {
            contentView.contentCollectionView.contentOffset.y = scrollView.contentOffset.y
        } else if scrollView == contentView.contentCollectionView {
            contentView.gradesCollectionView.contentOffset.y = scrollView.contentOffset.y
            gradesView.scrollView.contentOffset.x = scrollView.contentOffset.x
        } else if scrollView == gradesView.scrollView {
            contentView.contentCollectionView.contentOffset.x = scrollView.contentOffset.x
        }
    }
}

extension GridView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        dataSource?.numberOfSections() ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == contentView.gradesCollectionView {
            return dataSource?.numberOfRowsForGradeCollectionView(in: section) ?? 0
        } else {
            return dataSource?.numberOfRowsForInfoCollectionView(in: section) ?? 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == contentView.gradesCollectionView {
            return dataSource?.cellForGradeCollectionView(collectionView, for: indexPath) ?? .init()
        } else {
            return dataSource?.cellForInfoCollectionView(collectionView, for: indexPath) ?? .init()
        }
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.layoutSubviews()
    }
}

extension GridView: GradesGridViewDataSource {

    func gradesGridViewCollectionNumberOfRows() -> Int {
        dataSource?.numberOfRowsForInfoCollectionView(in: 0) ?? 0
    }

    func gradesGridViewCollectionTitle(for row: Int) -> NSAttributedString? {
        dataSource?.gradeTitleForInfoCollectionView(at: row)
    }

    func gradesGridViewTableTitle() -> NSAttributedString? {
        dataSource?.gradeTitleForGradeCollectionView()
    }
}

extension GridView {

    struct GridViewConstructor {
        let rowsCount: Int
        let gradeHeight: CGFloat
        let collectionColumnWidth: CGFloat
        let tableColumnWidth: CGFloat
    }
}
