//
//  UserNotificationsProtocol.swift
//  
//
//  Created by Yaroslav Babalich on 28.04.2021.
//

import UserNotifications

public protocol UserNotifications {
    /// asking permisioms for local notifications
    func askPermissions(with options: UNAuthorizationOptions, completion: @escaping BoolClosure)

    /// add notification request with optional category(could be actions buttons)
    func add(notificationRequest: UNNotificationRequest, with category: UNNotificationCategory?)

    /// this method will remove all pending and delivered requests with specific identifier
    func removeAllNotifications(with identifier: String)

    /// this method will remove all pending and delivered requests 
    func removeAllNotifications()
}
