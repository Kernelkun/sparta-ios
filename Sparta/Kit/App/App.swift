//
//  App.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 25.11.2020.
//

import Foundation
import Networking
import NetworkingModels
import Reachability

protocol AppFlowDelegate: AnyObject {
    func appFlowDidUpdate()
}

class App {
    
    // MARK: - Singleton
    
    static let instance = App()
    
    //
    // MARK: - Utilities

    let keychain = KeychainManager()
    let syncService = SyncService()

    // sockets managers

    let blenderSyncManager: BlenderSyncManager
    let liveCurvesSyncManager: LiveCurvesSyncManagerProtocol
    let arbsSyncManager: ArbsSyncInterface
    let sockets: SocketAPI
    
    weak var delegate: AppFlowDelegate?

    // MARK: - Private properties

    private let stateService: AppStateService
    private let reachability: Reachability
    
    // MARK: - Public properties
    
    /// SESSION INFO
    
    var isSignedIn: Bool {

        let cachedToken: String? = keychain.retrieve(.accessToken, from: .userData)

        return cachedToken?.nullable != nil
    }
    
    var token: String? {
        keychain.retrieve(.accessToken, from: .userData)
    }

    // can be changed just via current class

    var isTokenSentToServer: Bool = false

    // app able to check just after success session start

    var isAccountConfirmed: Bool {
        currentUser?.isConfirmed ?? false
    }

    var isInitialDataSynced: Bool {
        syncService.isInitialDataSynced
    }

    private(set) var currentUser: User?

    /// OPTIONS VALUES
    
    /*var environmentType: Environment.EnvironmentType {
        options?.environment ?? .development
    }*/
    
    // MARK: - Private properties
    
    // MARK: - Initializers
    
    init() {

        blenderSyncManager = BlenderSyncManager.intance
        liveCurvesSyncManager = LiveCurvesSyncManager()
        arbsSyncManager = ArbsSyncManager()
        stateService = AppStateService()

        reachability = try! Reachability() // swiftlint:disable:this force_try
        try! reachability.startNotifier() // swiftlint:disable:this force_try

        sockets = SocketAPI()
        sockets.connectionDelegate = self

        syncService.delegate = self
        stateService.delegate = self

        // internet

        setupInternetConnectionEvents()
    }
    
    // MARK: - Public methods

    func syncInitialData() {
        syncService.syncInitialData()
    }

    func appDidMakeAuthentication() {

        // sockets connection

        connectToSockets()

        // identify

        guard let user = currentUser else { return }

        AnalyticsManager.intance.identity(user)
    }

    func saveLoginData(_ loginData: Login) {
        self.currentUser = loginData.user
        try? keychain.save(loginData.jwt, as: .accessToken, to: .userData)
    }

    func saveUser(_ user: User) {
        self.currentUser = user
    }
    
    func logout() {
        try! keychain.reset() //swiftlint:disable:this force_try
        sockets.disconnect(forced: true)
        currentUser = nil

        delegate?.appFlowDidUpdate()
    }

    // MARK: - Private methods

    private func setupInternetConnectionEvents() {

        reachability.whenReachable = { [unowned self] _ in
            self.connectToSockets()
        }

        reachability.whenUnreachable = { _ in
            self.isTokenSentToServer = false
            self.sockets.disconnect(forced: true)
        }
    }

    private func connectToSockets() {
        guard isSignedIn else { return }

        socketsConnect()
    }
}

extension App: SyncServiceDelegate {

    func syncServiceDidFinishSyncInitialData() {

        if let currentUser = syncService.currentUser {
            saveUser(currentUser)
        }

        delegate?.appFlowDidUpdate()
    }
}

extension App: AppStateServiceDelegate {

    func appStateServiceDidUpdateState() {
        if stateService.isActiveApp
            && syncService.currentUser != nil {
            
            connectToSockets()
        } else {
            sockets.disconnect(forced: true)
        }
    }
}
