//
//  SearchViewInterfaces.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 10.02.2022.
//

//import UIKit
//import NetworkingModels
//
//protocol SearchableItem: ListableItem {
//    var isActive: Bool { get }
//}
//
//protocol SearchableGroup {
//    var items: [SearchableItem] { get }
//}
//
//protocol SearchViewModelDelegate: AnyObject {
//    func didCatchAnError(_ error: String)
//    func didChangeLoadingState(_ isLoading: Bool)
//    func didSuccessFetchList()
//    func didSuccessChooseItem()
//}
//
//protocol SearchViewModelInterface {
//    var delegate: SearchViewModelDelegate? { get set }
//
//    func loadData()
//    func search(query: String?)
//    func chooseItem(_ item: SearchableItem)
//}
