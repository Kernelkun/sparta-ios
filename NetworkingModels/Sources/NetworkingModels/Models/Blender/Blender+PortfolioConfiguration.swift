//
//  Blender+PortfolioConfiguration.swift
//  
//
//  Created by Yaroslav Babalich on 06.10.2021.
//

import Foundation
import SwiftyJSON

extension Blender {

    public struct PortfolioConfiguration: BackendModel {

        //
        // MARK: - Public properties

        public let id: Int?
        public let name: String?

        //
        // MARK: - Default Initializers

        public init(json: JSON) {
            id = json["blendConfigurationId"].int
            name = json["blenderConfigurationName"].string
        }
    }
}
