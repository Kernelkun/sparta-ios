//
//  GradesGridView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 14.12.2020.
//

import UIKit

protocol GradesGridViewDelegate: class {

}

protocol GradesGridViewDataSource: class {
}

class GradesGridView: UIView {

    // MARK: - UI

    var scrollView: UIScrollView!

    private var notScrollableView: UIView!

    // MARK: - Public properties

    weak var delegate: GradesGridViewDelegate?
    weak var dataSource: GradesGridViewDataSource?

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

    // MARK: - Private methods

    private func setupUI() {

        notScrollableView = UIView().then { view in

            view.backgroundColor = UIBlenderConstants.evenLineBackgroundColor

            addSubview(view) {
                $0.left.equalToSuperview().offset(18)
                $0.top.bottom.equalToSuperview()
                $0.width.equalTo(130)
            }
        }

        scrollView = UIScrollView().then { view in

            view.backgroundColor = .clear
            view.showsHorizontalScrollIndicator = false
            view.showsVerticalScrollIndicator = false
            view.bounces = false

            addSubview(view) {
                $0.left.equalTo(notScrollableView.snp.right)
                $0.top.bottom.right.equalToSuperview()
            }
        }

        _ = UIStackView().then { stackView in

            stackView.axis = .horizontal
            stackView.distribution = .equalSpacing
            stackView.spacing = 0
            stackView.alignment = .leading

            for _ in 0...6 {
                let gridCell = BlenderGradeCollectionViewCell()
                gridCell.apply(title: "Grade", for: IndexPath(row: 0, section: 0))

                stackView.addArrangedSubview(gridCell)

                gridCell.snp.makeConstraints {
                    $0.size.equalTo(CGSize(width: 100, height: 50))
                }
            }

            scrollView.contentSize = CGSize(width: 6 * 100, height: 50)

            scrollView.addSubview(stackView) {
                $0.left.right.equalToSuperview()
                $0.centerY.equalToSuperview()
            }
        }
    }
}
