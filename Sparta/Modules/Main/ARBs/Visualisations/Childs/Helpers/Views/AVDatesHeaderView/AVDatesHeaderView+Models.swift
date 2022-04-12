//
//  AVDatesHeaderView+Models.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 11.04.2022.
//

import Foundation

extension AVDatesHeaderView {
    struct Header {
        let title: String
        let subTitle: String
    }

    struct Configurator {
        let headers: [Header]
    }
}
