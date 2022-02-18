//
//  Globals.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 18.02.2022.
//

import UIKit.UIImage

public func onMainThread(delay: TimeInterval = 0, _ block: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) { block() }
}

var appCoordinator: AppCoordinator!

struct AppFormatter {

    // dates

    static let fullMonthAndYear = "MMMM yyyy"
    static let statWeek = "YYYY w"
    static let day = "EEEEE"
    static let listDate = "dd MMM, hh:mm"
    static let timeDate = "HH:mm:ss"
    static let serverLongDate = "yyyy-MM-dd hh:mm:ss"
    static let serverLongDateWithT = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    static let serverShortDate = "yyyy-MM-dd"


    struct Restrictions {
        static let maxPortfolioNameLength: Int = 25
        static let maxPortfolioItemsNumbers: Int = 40
    }
}

