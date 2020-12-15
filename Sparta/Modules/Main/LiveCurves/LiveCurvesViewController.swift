//
//  LiveCurvesViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 10.12.2020.
//

import UIKit

class LiveCurvesViewController: BaseVMViewController<LiveCurvesViewModel> {

    // MARK: - UI

    private let gridView: GridView

    // MARK: - Private properties

    // MARK: - Initializers

    init() {
        gridView = GridView()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = gridView
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // UI

        setupUI()
        setupNavigationUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // view model

        viewModel.delegate = self
        viewModel.loadData()

        gridView.apply(topSpace: topBarHeight)
    }

    // MARK: - Private methods

    private func setupUI() {

//        view.backgroundColor = UIColor(hex: 0x1D1D1D).withAlphaComponent(0.94)

//        gridView.delegate = self
        gridView.dataSource = self
    }

    private func setupNavigationUI() {
        navigationItem.title = nil

        navigationItem.leftBarButtonItem = UIBarButtonItemFactory.titleButton(text: "Live Curves")
    }
}

extension LiveCurvesViewController: GridViewDelegate, GridViewDataSource {

    func numberOfSections() -> Int {
        20
    }

    func sectionHeight(_ section: Int) -> CGFloat {
        50
    }

    func numberOfRowsForTableView(in section: Int) -> Int {
        1
    }

    func numberOfRowsForCollectionView(in section: Int) -> Int {
        6
    }

    func cellForTableView(_ tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell {
        let cell: BlenderGradeTableViewCell = tableView.dequeueReusableCell(for: indexPath)

        let title = indexPath.section == 0 ? "Grade" : "Test"

        cell.apply(title: title, for: indexPath)

        return cell
    }

    func cellForCollectionView(_ collectionView: UICollectionView, for indexPath: IndexPath) -> UICollectionViewCell {
        let cell: BlenderGradeCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)

        let title = indexPath.section == 0 ? "Grade" : "Test"

        cell.apply(title: title, for: indexPath)

        return cell
    }
}

extension LiveCurvesViewController: LiveCurvesViewModelDelegate {
}
