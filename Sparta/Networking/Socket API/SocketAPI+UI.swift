//
//  SocketAPI+UI.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 23.12.2020.
//

import UIKit
import Networking

extension SocketAPI.State {
    
    var color: UIColor {
        if self < .connecting {
            return .red
        } else if self == .connecting {
            return .yellow
        } else if self >= .connected {
            return .green
        }

        return .clear
    }

    var title: String {
        if self < .connecting {
            return "Closed"
        } else if self == .connecting {
            return "Connecting"
        } else if self >= .connected {
            return "Connected"
        }

        return ""
    }
}
