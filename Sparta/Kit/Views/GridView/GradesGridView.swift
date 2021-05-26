//
//  GradesGridView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 14.12.2020.
//

import UIKit

protocol GradesGridViewDataSource: AnyObject {
    func gradesGridViewGradeHeight() -> CGFloat
    func gradesGridViewScrollableGradeWidth() -> CGFloat
    func gradesGridViewNonScrollableGradeWidth() -> CGFloat
    func gradesGridViewCollectionNumberOfRows() -> Int
    func gradesGridViewCollectionTitle(for row: Int) -> NSAttributedString?
    func gradesGridViewTableTitle() -> NSAttributedString?
}

class GradesGridView: UIView {

    // MARK: - UI

    var scrollView: UIScrollView!

    private var tableGradeView: GradeTitleView!
    private var notScrollableView: UIView!
    private var gradesStackView: UIStackView!

    // MARK: - Private properties

    private let dataSource: GradesGridViewDataSource

    // MARK: - Initializers

    init(dataSource: GradesGridViewDataSource) {
        self.dataSource = dataSource

        super.init(frame: .zero)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public methods

    func reloadData(force: Bool = false) {
        if force {
            // stack view data
            gradesStackView.removeAllSubviews()

            for _ in 0..<dataSource.gradesGridViewCollectionNumberOfRows() {
                let gridCell = GradeTitleView(insets: .zero)
                gradesStackView.addArrangedSubview(gridCell)

                gridCell.snp.remakeConstraints {
                    $0.size.equalTo(CGSize(width: dataSource.gradesGridViewScrollableGradeWidth(),
                                           height: dataSource.gradesGridViewGradeHeight()))
                }
            }

            // scroll view content size

            scrollView.contentSize = scrollViewContentSize()
        }

        for (row, gridCell) in gradesStackView.arrangedSubviews.enumerated() {
            (gridCell as? GradeTitleView)?.apply(text: dataSource.gradesGridViewCollectionTitle(for: row))
        }

        tableGradeView.apply(text: dataSource.gradesGridViewTableTitle())
    }

    // MARK: - Private methods

    private func setupUI() {

        backgroundColor = UIGridViewConstants.mainBackgroundColor

        notScrollableView = UIView().then { view in

            view.backgroundColor = UIGridViewConstants.evenLineBackgroundColor

            tableGradeView = GradeTitleView(insets: .init(top: 0, left: 8, bottom: 0, right: 0))
            view.addSubview(tableGradeView) {
                $0.edges.equalToSuperview()
            }

            addSubview(view) {
                $0.left.equalToSuperview()
                $0.top.bottom.equalToSuperview()
                $0.width.equalTo(dataSource.gradesGridViewNonScrollableGradeWidth())
            }
        }

        scrollView = UIScrollView().then { view in

            view.backgroundColor = .clear
            view.showsHorizontalScrollIndicator = false
            view.showsVerticalScrollIndicator = false
            view.bounces = false
            view.contentSize = scrollViewContentSize()

                addSubview(view) {
                    $0.left.equalTo(notScrollableView.snp.right)
                    $0.top.bottom.right.equalToSuperview()
                }
        }

        gradesStackView = UIStackView().then { stackView in

            stackView.axis = .horizontal
            stackView.distribution = .equalSpacing
            stackView.spacing = 0
            stackView.alignment = .leading

            for _ in 0..<dataSource.gradesGridViewCollectionNumberOfRows() {
                let gridCell = GradeTitleView(insets: .zero)
                stackView.addArrangedSubview(gridCell)

                gridCell.snp.makeConstraints {
                    $0.size.equalTo(CGSize(width: dataSource.gradesGridViewScrollableGradeWidth(),
                                           height: dataSource.gradesGridViewGradeHeight()))
                }
            }

            scrollView.addSubview(stackView) {
                $0.left.right.equalToSuperview()
                $0.centerY.equalToSuperview()
            }
        }
    }

    private func scrollViewContentSize() -> CGSize {
        CGSize(width: dataSource.gradesGridViewScrollableGradeWidth() * CGFloat(dataSource.gradesGridViewCollectionNumberOfRows()),
               height: dataSource.gradesGridViewGradeHeight())
    }
}
