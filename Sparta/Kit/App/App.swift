//
//  App.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 25.11.2020.
//

import Foundation
import Networking
import NetworkingModels

protocol AppFlowDelegate: class {
    func appFlowDidUpdate()
}

class App {
    
    // MARK: - Singleton
    
    static let instance = App()
    
    //
    // MARK: - Utilities

    let keychain = KeychainManager()
    let syncService = SyncService()
    let sockets: SocketAPI
    
    weak var delegate: AppFlowDelegate?
    
    // MARK: - Public properties
    
    /// SESSION INFO
    
    var isSignedIn: Bool {

        let cachedToken: String? = keychain.retrieve(.accessToken, from: .userData)

        return cachedToken?.nullable != nil
    }
    
    var token: String? {
        keychain.retrieve(.accessToken, from: .userData)
    }

    // app able to check just after success session start
    var isAccountConfirmed: Bool {
        currentUser?.isConfirmed ?? false
    }

    private(set) var currentUser: User?

    /// OPTIONS VALUES
    
    /*var environmentType: Environment.EnvironmentType {
        options?.environment ?? .development
    }*/
    
    // MARK: - Private properties
    
    // MARK: - Initializers
    
    init() {
        sockets = SocketAPI(defaultServer: .blender)
        sockets.connectionDelegate = self

        syncService.delegate = self
    }
    
    // MARK: - Public methods
    
    func saveLoginData(_ loginData: Login) {
        self.currentUser = loginData.user
        try? keychain.save(loginData.jwt, as: .accessToken, to: .userData)
    }

    func saveUser(_ user: User) {
        self.currentUser = user
    }
    
    func logout() {
        try! keychain.reset() //swiftlint:disable:this force_try

        delegate?.appFlowDidUpdate()
    }
}

extension App: SyncServiceDelegate {
}
