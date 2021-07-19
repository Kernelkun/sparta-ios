//
//  BlenderDescriptionPopupViewModel.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 22.12.2020.
//

import Foundation

protocol BlenderDescriptionPopupViewModelDelegate: AnyObject {
    func didLoadData()
}

class BlenderDescriptionPopupViewModel {

    // MARK: - Public properties

    var monthDetails: BlenderMonthDetailModel?
    var sections: [Section] = []

    weak var delegate: BlenderDescriptionPopupViewModelDelegate?

    // MARK: - Public methods

    func loadData() {
        guard var monthDetails = monthDetails else {
            sections = []
            delegate?.didLoadData()
            return
        }

        monthDetails.mainKeyValues.sort(by: { $0.priorityIndex < $1.priorityIndex })
        monthDetails.componentsKeyValues.sort(by: { $0.priorityIndex < $1.priorityIndex })

        var firstSection = Section(cells: [])
        var secondSection = Section(cells: [])

        monthDetails.mainKeyValues.forEach { value in
            firstSection.cells.append(value)
        }

        monthDetails.componentsKeyValues.forEach { value in
            secondSection.cells.append(value)
        }

        sections = [firstSection, secondSection]

        delegate?.didLoadData()
    }
}

extension BlenderDescriptionPopupViewModel {
    struct Section {
        var cells: [BlenderMonthDetailModel.KeyValueParameter]
    }
}
