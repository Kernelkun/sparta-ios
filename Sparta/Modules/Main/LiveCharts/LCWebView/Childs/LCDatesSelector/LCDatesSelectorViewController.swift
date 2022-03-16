//
//  LCDatesSelectorViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 13.02.2022.
//

import UIKit
import PanModal
import SpartaHelpers
import NetworkingModels

protocol LCDatesSelectorViewCoordinatorDelegate: AnyObject {
    func lcDatesSelectorViewDidChooseDate(_ viewController: LCDatesSelectorViewController, dateSelector: LiveChartDateSelector)
}

class LCDatesSelectorViewController: UIViewController {

    // MARK: - Public properties

    weak var coordinatorDelegate: LCDatesSelectorViewCoordinatorDelegate?

    // MARK: - UI

    private var tableView: UITableView!

    // MARK: - Private properties

    private let viewModel: LCDatesSelectorViewModel

    // MARK: - Initializers

    init(viewModel: LCDatesSelectorViewModel) {
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
    }

    // MARK: - Private methods

    private func setupUI() {
        view.backgroundColor = .neutral85

        let arrowButton = TappableButton().then { button in

            button.setImage(UIImage(systemName: "chevron.compact.down")?.withTintColor(.controlTintActive, renderingMode: .alwaysTemplate),
                            for: .normal)

            addSubview(button) {
                $0.top.equalToSuperview().offset(7)
                $0.size.equalTo(CGSize(width: 14.2, height: 4.3))
                $0.centerX.equalToSuperview()
            }
        }

        tableView = ContentSizedTableView().then { tableView in

            if #available(iOS 15.0, *) {
                tableView.sectionHeaderTopPadding = 0
            }

            tableView.backgroundColor = .clear
            tableView.tableFooterView = UIView(frame: .zero)
            tableView.separatorStyle = .none
            tableView.showsVerticalScrollIndicator = false
            tableView.showsHorizontalScrollIndicator = false
            tableView.rowHeight = UITableView.automaticDimension

            tableView.register(LCDatesSelectorTableViewCell.self)
            tableView.register(LCDatesSelectorHeaderTableView.self)

            tableView.delegate = self
            tableView.dataSource = self

            addSubview(tableView) {
                $0.top.equalTo(arrowButton.snp.bottom).offset(20)
                $0.left.right.bottom.equalToSuperview()
            }
        }
    }
}

extension LCDatesSelectorViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.groups.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: LCDatesSelectorTableViewCell = tableView.dequeueReusableCell(for: indexPath)

        let dateSelectors = viewModel.groups[indexPath.section].dateSelectors
        
        cell.apply(
            dateSelectors: dateSelectors,
            selectedDateSelector: viewModel.selectedDateSelector) { [unowned self] dateSelector in
                viewModel.chooseDate(dateSelector)
            }

        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view: LCDatesSelectorHeaderTableView = tableView.dequeueReusableHeaderFooterView()

        let group = viewModel.groups[section]
        view.apply(title: group.name.capitalized)

        return view
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        20
    }
}

extension LCDatesSelectorViewController: PanModalPresentable {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    var panScrollable: UIScrollView? {
        return tableView
    }

    var longFormHeight: PanModalHeight {
        return .intrinsicHeight
    }

    var anchorModalToLongForm: Bool {
        return false
    }

    var dragIndicatorBackgroundColor: UIColor {
        .clear
    }

    var panModalBackgroundColor: UIColor {
        .neutral100.withAlphaComponent(0.5)
    }
}

extension LCDatesSelectorViewController: LCDatesSelectorViewModelDelegate {

    func didCatchAnError(_ error: String) {
    }

    func didChangeLoadingState(_ isLoading: Bool) {
    }

    func didSuccessFetchList() {
        tableView.reloadData()
    }

    func didSuccessChooseDate(_ dateSelector: LiveChartDateSelector) {
        coordinatorDelegate?.lcDatesSelectorViewDidChooseDate(self, dateSelector: dateSelector)
        dismiss(animated: true, completion: nil)
    }
}
