//
//  BlenderDescriptionPopupView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 04.12.2020.
//

import UIKit
import SpartaHelpers

class BlenderDescriptionPopupView: UIView {

    // MARK: - Public properties

    var calculatedHeight: CGFloat {
        tableView.layoutIfNeeded()
        return tableView.contentSize.height + 20 + 8
    }

    // MARK: - Private properties

    private let viewModel = BlenderDescriptionPopupViewModel()
    private var tableView: UITableView!

    private var _closeClosure: EmptyClosure?
    private var _contentChangeSizeClosure: EmptyClosure?

    // MARK: - Initializers

    init() {
        super.init(frame: .zero)

        // UI

        setupUI()

        // view model

        viewModel.delegate = self
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        // UI

        setupUI()

        // view model

        viewModel.delegate = self
    }

    // MARK: - Public methods

    func apply(monthDetailModel: BlenderMonthDetailModel) {
        viewModel.monthDetails = monthDetailModel
        viewModel.loadData()
    }

    func onClose(completion: @escaping EmptyClosure) {
        _closeClosure = completion
    }

    func onContentChangeSize(completion: @escaping EmptyClosure) {
        _contentChangeSizeClosure = completion
    }

    // MARK: - Private methods

    private func setupUI() {

        // UI
        backgroundColor = .secondaryBackground
        applyCorners(4)
        layer.borderWidth = 1
        layer.borderColor = UIColor.mainBackground.cgColor

        tableView = UITableView().then { tableView in

            tableView.applyCorners(4)
            tableView.backgroundColor = .mainBackground
            tableView.tableFooterView = UIView(frame: .zero)
            tableView.separatorStyle = .none
            tableView.showsVerticalScrollIndicator = false
            tableView.showsHorizontalScrollIndicator = false
            tableView.rowHeight = UITableView.automaticDimension

            tableView.register(BlenderDescriptionPopupHeaderView.self)
            tableView.register(BlenderDescriptionTableViewCell.self)

            tableView.delegate = self
            tableView.dataSource = self

            addSubview(tableView) {
                $0.left.right.bottom.equalToSuperview().inset(8)
                $0.top.equalToSuperview().offset(20)
            }
        }

        _ = TappableButton(type: .custom).then { button in

            button.clickableInset = -20
            button.setBackgroundImage(UIImage(named: "ic_close"), for: .normal)

            button.onTap { [unowned self] _ in
                self._closeClosure?()
            }

            addSubview(button) {
                $0.size.equalTo(10)
                $0.top.equalToSuperview().offset(5)
                $0.right.equalToSuperview().inset(10)
            }
        }

        tableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize" {
            if let newvalue = change?[.newKey] {

                if let newsize = newvalue as? CGSize {
                    print("new size \(newsize)")
                    _contentChangeSizeClosure?()
                }
            }
        }
    }
}

extension BlenderDescriptionPopupView: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.sections[section].cells.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let model = viewModel.sections[indexPath.section].cells[indexPath.row]

        let cell: BlenderDescriptionTableViewCell = tableView.dequeueReusableCell(for: indexPath)

        cell.apply(key: model.key, value: model.value)

        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            let view: BlenderDescriptionPopupHeaderView? = tableView.dequeueReusableHeaderFooterView()
            return view
        }

        return nil
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 40
    }
}

extension BlenderDescriptionPopupView: BlenderDescriptionPopupViewModelDelegate {
    func didLoadData() {
        tableView.reloadData()
    }
}
