//
//  SearchViewModel.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 13.02.2022.
//

import Foundation

protocol SearchViewModelDelegate: AnyObject {
    func didCatchAnError(_ error: String)
    func didChangeLoadingState(_ isLoading: Bool)
    func didSuccessFetchList()
    func didSuccessChooseItem()
}

class SearchViewModel<I: PickerValued> {

    // MARK: - Public properties

    weak var delegate: SearchViewModelDelegate?

    // MARK: - Public methods

    func loadData() {}

    func search(query: String?) {}

    func chooseItem(_ item: I) {

    }
}
