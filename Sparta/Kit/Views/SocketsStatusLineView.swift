//
//  SocketsStatusLineView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 23.12.2020.
//

import UIKit

class SocketsStatusLineView: UIView {

    // MARK: - UI

    private var statusMarkerView: UIView!
    private var statusLabel: UILabel!
    private var dateLabel: UILabel!

    // MARK: - Initializers

    init() {
        super.init(frame: .zero)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("SocketsStatusLineView")
    }

    // MARK: - Public methods

    func apply(color: UIColor, title: String, formattedDate: String?) {
        statusMarkerView.backgroundColor = color
        statusLabel.textColor = color
        statusLabel.text = title
        updateStatusLabel(with: formattedDate)
    }

    // MARK: - Private methods

    private func setupUI() {

        backgroundColor = .gray

        statusMarkerView = UIView().then { view in

            view.layer.cornerRadius = 3.5
            view.backgroundColor = .clear

            addSubview(view) {
                $0.size.equalTo(7)
                $0.left.equalToSuperview().offset(23)
                $0.centerY.equalToSuperview()
            }
        }

        statusLabel = UILabel().then { label in

            label.textAlignment = .left
            label.numberOfLines = 1
            label.font = .main(weight: .regular, size: 12)

            addSubview(label) {
                $0.left.equalTo(statusMarkerView.snp.right).offset(4)
                $0.centerY.equalTo(statusMarkerView)
            }
        }

        dateLabel = UILabel().then { label in

            label.textAlignment = .right
            label.numberOfLines = 1
            label.font = .main(weight: .regular, size: 12)
            label.textColor = .secondaryText

            addSubview(label) {
                $0.right.equalToSuperview().inset(23)
                $0.centerY.equalToSuperview()
            }
        }

        layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.53).cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = .zero
        layer.shadowRadius = 6
    }

    private func updateStatusLabel(with text: String?) {
        guard let text = text else {
            dateLabel.text = nil
            return
        }

        dateLabel.text = "LastUpdated.Title".localized + " " + text
    }
}
