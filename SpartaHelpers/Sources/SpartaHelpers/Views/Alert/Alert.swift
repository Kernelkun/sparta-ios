//
//  Alert.swift
//  
//
//  Created by Yaroslav Babalich on 21.01.2021.
//

import UIKit

public typealias AlertClosure = (_ index: Int) -> Void
public typealias AlertActionClosure = (AlertAction) -> Void

public struct AlertAction: Equatable {

    // MARK: - Public properties

    public let title: String?
    public let style: UIAlertAction.Style

    public init(title: String?, style: UIAlertAction.Style) {
        self.title = title
        self.style = style
    }

    public init(from action: UIAlertAction) {
        title = action.title
        style = action.style
    }

    // MARK: - Equatable
    public static func == (lhs: AlertAction, rhs: AlertAction) -> Bool {
        return lhs.title == rhs.title && lhs.style == rhs.style
    }
}

open class Alert: NSObject {

    // MARK: - Variables

    public var alertController: UIAlertController?

    // MARK: - Class methods
    @discardableResult
    public class func alert(title: String?,
                            message: String?,
                            preferredStyle: UIAlertController.Style) -> Alert {

        let alert = Alert()
        let alertController = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        alert.alertController = alertController
        return alert
    }

    @discardableResult
    public class func showNoYes(title: String?,
                                message: String?,
                                show controller: UIViewController!,
                                completion: AlertClosure?) -> Alert {

        let alert = Alert.alert(title: title, message: message, preferredStyle: .alert)

        let yesAction = UIAlertAction(title: "Yes", style: .default) { _ in
            completion?(1)
        }

        let noAction = UIAlertAction(title: "No", style: .cancel) { _ in
            completion?(0)
        }

        alert.alertController?.addAction(yesAction)
        alert.alertController?.addAction(noAction)
        alert.show(in: controller)
        return alert
    }

    @discardableResult
    public class func showOk(title: String?,
                             message: String?,
                             show controller: UIViewController?,
                             completion: AlertClosure?) -> Alert {

        let alert = Alert.alert(title: title, message: message, preferredStyle: .alert)

        let okAction = UIAlertAction(title: "Ok", style: .default) { _ in
            completion?(0)
        }

        alert.alertController?.addAction(okAction)
        alert.show(in: controller)
        return alert
    }

    @discardableResult
    public class func show(title: String?,
                           message: String?,
                           actions: [AlertAction],
                           in controller: UIViewController?,
                           completion: AlertActionClosure?) -> Alert {

        let alert = Alert.alert(title: title, message: message, preferredStyle: .alert)
        actions.forEach { action in
            alert.add(action: action, completion: completion)
        }
        alert.show(in: controller)
        return alert
    }

    // MARK: - Public methods

    public func add(action: AlertAction, completion: AlertActionClosure?) {
        guard let alertController = alertController else { return }

        let uiAlertAction = UIAlertAction(title: action.title, style: action.style, handler: { action in
            completion?(AlertAction(from: action))
        })
        alertController.addAction(uiAlertAction)
    }

    public func show(in controller: UIViewController?) {
        guard let alertController = alertController else { return }

        func showFrom(controller: UIViewController) {
            controller.present(alertController, animated: true, completion: nil)
        }

        if let controller = controller {
            showFrom(controller: controller)
        } else {
            if let topController = UIViewController.topController {
                showFrom(controller: topController)
            }
        }
    }

    public func show(from navigation: UINavigationController) {
        guard let alertController = alertController else { return }

        navigation.present(alertController, animated: true, completion: nil)
    }
}
