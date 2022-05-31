//
//  LCWeb+Restrictions.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 16.02.2022.
//

import Foundation

enum LCWebRestriction {
    static let defaultItemCode: String = "OTREOB"
    static let validItemsCodes: [String] = ["OTRBSW", "OTREOB", "OTRROB",
                                            "OTRMPS", "OTRNWE", "TSDEOB",
                                            /*"TSDROB",*/ "SPDROB", "TSDMPS",
                                            "ISPEOB", "SPDMEB", "ISPENW",
                                            "ISPMPS", "TSDNWE", "ISPNWE",
                                            "PSDREB", "SPDMEN", "SPDMJN",
                                            "OTRWTS", "OB-DIFGCPMLF", "OB-DIFGCPALF",
                                            "MB5ROB", "MB4ROB"]
    static let validDateSelectors: [String] = []
}
