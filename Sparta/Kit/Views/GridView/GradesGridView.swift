//
//  GradesGridView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 14.12.2020.
//

import UIKit

protocol GradesGridViewDataSource: class {
    func gradesGridViewCollectionNumberOfRows() -> Int
    func gradesGridViewCollectionTitle(for row: Int) -> String
    func gradesGridViewTableTitle() -> String
}

class GradesGridView: UIView {

    // MARK: - UI

    var scrollView: UIScrollView!

    private var tableGradeView: GradeTitleView!
    private var notScrollableView: UIView!
    private var gradesStackView: UIStackView!

    // MARK: - Public properties

    weak var dataSource: GradesGridViewDataSource?

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
        for (row, gridCell) in gradesStackView.arrangedSubviews.enumerated() {
            (gridCell as? GradeTitleView)?.apply(title: dataSource?.gradesGridViewCollectionTitle(for: row) ?? "")
        }
    }

    // MARK: - Private methods

    private func setupUI() {

        backgroundColor = UIGridViewConstants.mainBackgroundColor

        notScrollableView = UIView().then { view in

            view.backgroundColor = UIBlenderConstants.evenLineBackgroundColor

            tableGradeView = GradeTitleView()
            view.addSubview(tableGradeView) {
                $0.edges.equalToSuperview()
            }

            addSubview(view) {
                $0.left.equalToSuperview().offset(18)
                $0.top.bottom.equalToSuperview()
                $0.width.equalTo(constructor.tableColumnWidth)
            }
        }

        scrollView = UIScrollView().then { view in

            view.backgroundColor = .clear
            view.showsHorizontalScrollIndicator = false
            view.showsVerticalScrollIndicator = false
            view.bounces = false
            view.contentSize = CGSize(width: constructor.collectionColumnWidth * CGFloat(constructor.monthsCount),
                                      height: constructor.gradeHeight)

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

            for _ in 0..<constructor.monthsCount {
                let gridCell = GradeTitleView()
                stackView.addArrangedSubview(gridCell)

                gridCell.snp.makeConstraints {
                    $0.size.equalTo(CGSize(width: constructor.collectionColumnWidth, height: constructor.gradeHeight))
                }
            }

            scrollView.addSubview(stackView) {
                $0.left.right.equalToSuperview()
                $0.centerY.equalToSuperview()
            }
        }
    }
}
