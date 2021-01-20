//
//  Keychain+Keys.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 27.11.2020.
//

import KeychainAccess

extension KeychainKey {
    static let accessToken: String = "accessTokenIdentifier"
    static let refreshToken: String = "refreshTokenIdentifier"
    static let deviceToken: String = "deviceTokenIndetifier" // push notifications token
}

extension KeychainStorage {
    static let userData: String = "com.spartacommodities.keychain.user.data"
}
