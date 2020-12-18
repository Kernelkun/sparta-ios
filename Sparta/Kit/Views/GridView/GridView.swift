//
//  GridView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 15.12.2020.
//

import UIKit

protocol GridViewDataSource: class {
    func numberOfSections() -> Int
    func sectionHeight(_ section: Int) -> CGFloat
    func numberOfRowsForTableView(in section: Int) -> Int
    func numberOfRowsForCollectionView(in section: Int) -> Int
    func cellForTableView(_ tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell
    func cellForCollectionView(_ collectionView: UICollectionView, for indexPath: IndexPath) -> UICollectionViewCell

    func gradeTitleForColectionView(at row: Int) -> String
    func gradeTitleForTableView(at row: Int) -> String
}

class GridView: UIView {

    // MARK: - Public properties

    weak var dataSource: GridViewDataSource?

    // MARK: - Private properties

    private var gradesView: GradesGridView!
    private var contentView: ContentGridView!

    // MARK: - Initializers

    init() {
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

    func reloadGrades() {
        gradesView.reloadData()
    }

    func updateDataSourceSections(insertions: IndexSet, removals: IndexSet, updates: IndexSet) {
        contentView.tableView.updateSections(insertions: insertions, removals: removals, updates: updates)
        contentView.collectionView.updateSections(insertions: insertions, removals: removals, updates: updates)
    }

    // MARK: - Private methods

    private func setupUI() {

        backgroundColor = UIGridViewConstants.mainBackgroundColor

        gradesView = GradesGridView().then { view in

            view.scrollView.delegate = self
            view.dataSource = self

            addSubview(view) {
                $0.top.equalToSuperview()
                $0.left.equalToSuperview()
                $0.right.equalToSuperview()
                $0.height.equalTo(50)
            }
        }

        contentView = ContentGridView().then { view in

            view.tableView.delegate = self
            view.tableView.dataSource = self

            view.collectionView.delegate = self
            view.collectionView.dataSource = self

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
        if scrollView == contentView.tableView {
            contentView.collectionView.contentOffset.y = scrollView.contentOffset.y
        } else if scrollView == contentView.collectionView {
            contentView.tableView.contentOffset.y = scrollView.contentOffset.y
            gradesView.scrollView.contentOffset.x = scrollView.contentOffset.x
        } else if scrollView == gradesView.scrollView {
            contentView.collectionView.contentOffset.x = scrollView.contentOffset.x
        }
    }
}

extension GridView: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        dataSource?.numberOfSections() ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource?.numberOfRowsForTableView(in: section) ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        dataSource?.cellForTableView(tableView, for: indexPath) ?? .init()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        dataSource?.sectionHeight(indexPath.section) ?? 0.0
    }
}

extension GridView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        dataSource?.numberOfSections() ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataSource?.numberOfRowsForCollectionView(in: section) ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        dataSource?.cellForCollectionView(collectionView, for: indexPath) ?? .init()
    }
}

extension GridView: GradesGridViewDataSource {
    func gradesGridViewCollectionNumberOfRows() -> Int {
        dataSource?.numberOfRowsForCollectionView(in: 0) ?? 0
    }

    func gradesGridViewCollectionTitle(for row: Int) -> String {
        dataSource?.gradeTitleForColectionView(at: row) ?? ""
    }

    func gradesGridViewTableTitle() -> String {
        ""
    }
}
