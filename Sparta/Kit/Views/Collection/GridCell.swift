//
//  GridCell.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 02.12.2020.
//

import UIKit

class GridCell: UICollectionViewCell {

    static var reuseIdentifier: String { return "cell" }

    override init(frame: CGRect) {
        super.init(frame: frame)
        label.frame = bounds.insetBy(dx: 2, dy: 2)
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.addSubview(label)

        let backgroundView = UIView(frame: CGRect(origin: .zero, size: frame.size))
        backgroundView.backgroundColor = .clear
        self.backgroundView = backgroundView

        bottomSeparator.backgroundColor = UIGridViewConstants.tableSeparatorLineColor
        backgroundView.addSubview(bottomSeparator)
    }

    func setRecord(_ record: String) {
        label.text = record
        label.textColor = .gray
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let size = bounds.size
        bottomSeparator.frame = CGRect(x: 0, y: size.height - CGFloat.separatorWidth, width: size.width, height: CGFloat.separatorWidth)
    }

    private let label = UILabel()
    private let bottomSeparator = UIView()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
