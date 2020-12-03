//
//  UITableView+Utilities.swift
//  
//
//  Created by Yaroslav Babalich on 02.12.2020.
//

import UIKit

public extension UITableView {

    func register<C: UITableViewCell>(_ cellType: C.Type) {
        register(cellType.self, forCellReuseIdentifier: cellType.reuseIdentifier)
    }

    func dequeueReusableCell<C: UITableViewCell>(for inexPath: IndexPath) -> C {
        guard let cell = dequeueReusableCell(withIdentifier: C.reuseIdentifier, for: inexPath) as? C else {
            fatalError("Could not dequeue cwhere C: ReusableViewell: \(C.reuseIdentifier)")
        }

        return cell
    }

    func update(insertions: [IndexPath],
                removals: [IndexPath],
                with animation: UITableView.RowAnimation,
                completion: ((Bool) -> Void)? = nil) {

        UIView.setAnimationsEnabled(false)
        performBatchUpdates({

            if !insertions.isEmpty {
                insertRows(at: insertions, with: animation)
            }

            if !removals.isEmpty {
                deleteRows(at: removals, with: animation)
            }
        }, completion: completion)
        UIView.setAnimationsEnabled(true)
    }

    func updateSections(insertions: IndexSet,
                        removals: IndexSet,
                        with animation: UITableView.RowAnimation,
                        completion: ((Bool) -> Void)? = nil) {

        DispatchQueue.main.async {
            UIView.setAnimationsEnabled(false)
            self.performBatchUpdates({

                if !insertions.isEmpty {
                    self.insertSections(insertions, with: animation)
                }

                if !removals.isEmpty {
                    self.deleteSections(removals, with: animation)
                }
            }, completion: completion)
            UIView.setAnimationsEnabled(true)
        }
    }

    func scrollToBottom(animated: Bool) {
        guard let dataSource = dataSource else { return }

        var lastSectionWithAtLeastOneElement = (dataSource.numberOfSections?(in: self) ?? 1) - 1
        while dataSource.tableView(self, numberOfRowsInSection: lastSectionWithAtLeastOneElement) < 1
            && lastSectionWithAtLeastOneElement > 0 {
                lastSectionWithAtLeastOneElement -= 1
        }

        let lastRow = dataSource.tableView(self, numberOfRowsInSection: lastSectionWithAtLeastOneElement) - 1
        guard lastSectionWithAtLeastOneElement > -1 && lastRow > -1 else { return }
        let bottomIndex = IndexPath(item: lastRow, section: lastSectionWithAtLeastOneElement)
        scrollToRow(at: bottomIndex, at: .bottom, animated: animated)
    }

    func scrollToTop(animated: Bool) {
        setContentOffset(.zero, animated: animated)
    }
}

