//
//  Keychain+Keys.swift
//  
//
//  Created by Yaroslav Babalich on 21.01.2021.
//

import KeychainAccess

public extension KeychainKey {
    static let accessToken: String = "accessTokenIdentifier"
    static let refreshToken: String = "refreshTokenIdentifier"
    static let deviceToken: String = "deviceTokenIndetifier" // push notifications token
}

public extension KeychainStorage {
    static let userData: String = "com.spartacommodities.keychain.user.data"
}
 
