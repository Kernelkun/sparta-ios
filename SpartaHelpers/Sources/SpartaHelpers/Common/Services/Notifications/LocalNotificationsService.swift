//
//  LocalNotificationsService.swift
//  
//
//  Created by Yaroslav Babalich on 28.04.2021.
//

import UserNotifications

open class LocalNotificationsService: NSObject, UserNotifications {

    // MARK: - Private properties

    private let notificationCenter = UNUserNotificationCenter.current()

    // MARK: - Initializers

    public override init() {
        super.init()
    }

    // MARK: - Public methods

    public func askPermissions(with options: UNAuthorizationOptions, completion: @escaping BoolClosure) {
        notificationCenter.requestAuthorization(options: options) { isGranted, _ in
            completion(isGranted)
        }
    }

    public func add(notificationRequest: UNNotificationRequest, with category: UNNotificationCategory?) {
        notificationCenter.add(notificationRequest) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }

        if let category = category {
            notificationCenter.setNotificationCategories([category])
        }
    }

    public func removeAllNotifications(with identifier: String) {
        notificationCenter.removeDeliveredNotifications(withIdentifiers: [identifier])
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    public func removeAllNotifications() {
        notificationCenter.removeAllDeliveredNotifications()
        notificationCenter.removeAllPendingNotificationRequests()
    }
}
