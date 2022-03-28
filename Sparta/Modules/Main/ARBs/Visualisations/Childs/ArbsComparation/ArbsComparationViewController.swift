//
//  ArbsComparationViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 27.12.2021.
//

import UIKit
import NetworkingModels
import SpartaHelpers

class ArbsComparationViewController: BaseViewController {

    // MARK: - Private properties

    private let viewModel: ArbsComparationViewModelInterface

    private var arbsSelector: UIMonthSelector<ArbV.Selector>!
    private var tableView: UITableView!

    // MARK: - Initializers

    init(viewModel: ArbsComparationViewModelInterface) {
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

        /*arbsSelector = UIMonthSelector<ArbV.Selector>().then { selector in

            addSubview(selector) {
                $0.left.top.equalToSuperview().inset(4)
                $0.size.equalTo(CGSize(width: 160, height: 31))
            }
        }*/

        let contentView = UIView().then { view in

            view.backgroundColor = .secondaryBackground
            view.layer.cornerRadius = 13

            addSubview(view) {
                $0.top.equalToSuperview().offset(4)
                $0.left.right.bottom.equalToSuperview().inset(4)
                $0.height.equalTo(300)
            }
        }

        /*let datesHeaderView = APPCDatesHeaderView().then { view in

            contentView.addSubview(view) {
                $0.left.top.equalToSuperview()
                $0.right.equalToSuperview().inset(8)
            }
        }

        tableView = ContentSizedTableView().then { tableView in

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
        }*/
    }
}

extension ArbsComparationViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell: APPCTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        return UITableViewCell()
    }
}

extension ArbsComparationViewController: ArbsComparationViewModelDelegate {

    func arbsPlaygroundPCViewModelDidFetchSelectors(_ selectors: [ArbV.Selector]) {
//        arbsSelector.inputValues = selectors
//        arbsSelector.apply(selectedValue: selectors.first.required())
    }
}
