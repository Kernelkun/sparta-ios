//
//  BlenderDescriptionPopupView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 04.12.2020.
//

import UIKit

class BlenderDescriptionPopupView: UIView {

    // MARK: - Private properties

    private var tableView: UITableView!

    private var model: BlenderMonthDetailModel?

    // MARK: - Initializers

    init() {
        super.init(frame: .zero)

        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupUI()
    }

    // MARK: - Public methods

    func apply(monthDetailModel: BlenderMonthDetailModel) {
        model = monthDetailModel
        tableView.reloadData()
    }

    // MARK: - Private methods

    private func setupUI() {

        backgroundColor = UIColor.red.withAlphaComponent(0.2)

        tableView = UITableView().then { tableView in

            tableView.backgroundColor = .clear
            tableView.tableFooterView = UIView(frame: .zero)
            tableView.separatorStyle = .none
            tableView.showsVerticalScrollIndicator = false
            tableView.showsHorizontalScrollIndicator = false
            tableView.rowHeight = UITableView.automaticDimension

            tableView.register(BlenderInfoTableViewCell.self)
            tableView.register(BlenderGradeTableViewCell.self)

            tableView.delegate = self
            tableView.dataSource = self

            addSubview(tableView) {
                $0.left.right.bottom.equalToSuperview().inset(8)
                $0.top.equalToSuperview().offset(18)
            }
        }
    }
}

extension BlenderDescriptionPopupView: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        guard model != nil else { return 0 }

        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let model = model else { return 0 }

        if section == 0 {
            return model.mainKeyValues.count
        } else {
            return model.componentsKeyValues.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let model = model else { return UITableViewCell() }

        let key: String
        let value: String

        var sectionValues: [String: String] = [:]

        if indexPath.section == 0 {
            sectionValues = model.mainKeyValues
        } else {
            sectionValues = model.componentsKeyValues
        }

        key = Array(sectionValues.keys)[indexPath.row]
        value = Array(sectionValues.values)[indexPath.row]

        let cell: BlenderInfoTableViewCell = tableView.dequeueReusableCell(for: indexPath)

        cell.apply(title: "\(key)    \(value)", for: indexPath)

        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40))
            view.backgroundColor = .yellow
            return view
        }

        return nil
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 40
    }
}
