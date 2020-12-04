//
//  UICollectionView+Utilities.swift
//  
//
//  Created by Yaroslav Babalich on 02.12.2020.
//

import UIKit

public extension UICollectionView {

    func register<C: UICollectionViewCell>(_ cellType: C.Type) {
        register(cellType.self, forCellWithReuseIdentifier: cellType.reuseIdentifier)
    }

    func dequeueReusableCell<C: UICollectionViewCell>(for inexPath: IndexPath) -> C {
        guard let cell = dequeueReusableCell(withReuseIdentifier: C.reuseIdentifier, for: inexPath) as? C else {
            fatalError("Could not dequeue cwhere C: ReusableViewell: \(C.reuseIdentifier)")
        }

        return cell
    }

    func update(insertions: [IndexPath],
                removals: [IndexPath],
                completion: ((Bool) -> Void)? = nil) {

        UIView.setAnimationsEnabled(false)
        performBatchUpdates({

            if !insertions.isEmpty {
                insertItems(at: insertions)
            }

            if !removals.isEmpty {
                deleteItems(at: removals)
            }
        }, completion: completion)
        UIView.setAnimationsEnabled(true)
    }

    func updateSections(insertions: IndexSet,
                        removals: IndexSet,
                        updates: IndexSet,
                        completion: ((Bool) -> Void)? = nil) {

        UIView.setAnimationsEnabled(false)
        performBatchUpdates({

            if !insertions.isEmpty {
                insertSections(insertions)
            }

            if !removals.isEmpty {
                deleteSections(removals)
            }

            if !updates.isEmpty {
                reloadSections(updates)
            }
        }, completion: completion)
        UIView.setAnimationsEnabled(true)
    }
}

