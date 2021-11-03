//
//  ArbsPlaygroundPCViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 28.10.2021.
//

import Foundation
import UIKit

class ArbsPlaygroundPCViewController: BaseViewController {

    // MARK: - Private properties

    private let viewModel: ArbsPlaygroundPCViewModelInterface

    private var tableView: UITableView!

    // MARK: - Initializers

    init(viewModel: ArbsPlaygroundPCViewModelInterface) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError(#function)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()

        // view model
        viewModel.loadData()
    }

    // MARK: - Private methods

    private func setupUI() {
        let contentView = UIView().then { view in

            view.backgroundColor = .secondaryBackground
            view.layer.cornerRadius = 13

            addSubview(view) {
                $0.edges.equalToSuperview().inset(4)
            }
        }

        let datesHeaderView = APPCDatesHeaderView().then { view in

            contentView.addSubview(view) {
                $0.left.right.top.equalToSuperview()
            }
        }

        tableView = UITableView().then { tableView in

            if #available(iOS 15.0, *) {
                tableView.sectionHeaderTopPadding = 0
            }

            tableView.backgroundColor = .clear
            tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 1))
            tableView.separatorStyle = .singleLine
            tableView.separatorColor = .secondaryText
            tableView.separatorInset = .zero
            tableView.showsVerticalScrollIndicator = true
            tableView.rowHeight = UITableView.automaticDimension
            tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -6)

            tableView.register(APPCTableViewCell.self)

            tableView.delegate = self
            tableView.dataSource = self

            contentView.addSubview(tableView) {
                $0.right.equalToSuperview().inset(6)
                $0.left.bottom.equalToSuperview()
                $0.top.equalTo(datesHeaderView.snp.bottom)
            }
        }
    }
}

extension ArbsPlaygroundPCViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: APPCTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        return cell
    }
}
