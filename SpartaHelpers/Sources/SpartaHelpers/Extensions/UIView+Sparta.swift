//
//  UIView+Sparta.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 27.11.2020.
//

import UIKit

public extension UIView {

    func rotate(degrees: CGFloat) {

        let degreesToRadians: (CGFloat) -> CGFloat = { (degrees: CGFloat) in
            return degrees / 180.0 * CGFloat.pi
        }

        transform = CGAffineTransform(rotationAngle: degreesToRadians(degrees))
    }

    func getMainGradient() -> CAGradientLayer {
        let layer0 = CAGradientLayer()

        layer0.colors = [
            UIColor(red: 0.129, green: 0.152, blue: 0.204, alpha: 1).cgColor,
            UIColor(red: 0.164, green: 0.198, blue: 0.271, alpha: 1).cgColor,
            UIColor(red: 0.029, green: 0.03, blue: 0.038, alpha: 1).cgColor
        ]
        layer0.locations = [0, 0, 0.85]
        layer0.startPoint = CGPoint(x: 0.25, y: 0.5)
        layer0.endPoint = CGPoint(x: 0.75, y: 0.5)
        layer0.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: 3.49, b: -3.88, c: 12.68,
                                                                              d: 8.07, tx: -7.99, ty: -1))
        layer0.bounds = bounds.insetBy(dx: -0.5 * bounds.size.width, dy: -0.5 * bounds.size.height)
        layer0.position = center

        return layer0
    }

    func getTrimmerGradient() -> CAGradientLayer {
        let layer0 = CAGradientLayer()

        layer0.colors = [
            UIColor(red: 0.129, green: 0.152, blue: 0.204, alpha: 1).cgColor,
            UIColor(red: 0.164, green: 0.198, blue: 0.271, alpha: 1).cgColor,
            UIColor(red: 0.029, green: 0.03, blue: 0.038, alpha: 1).cgColor
        ]
        layer0.locations = [0, 0, 0.85]
        layer0.startPoint = CGPoint(x: 0.25, y: 0.5)
        layer0.endPoint = CGPoint(x: 0.75, y: 0.5)
        layer0.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: 3.49, b: -3.88, c: 12.68,
                                                                              d: 8.07, tx: -7.99, ty: -1))
        layer0.bounds = bounds.insetBy(dx: -0.5 * bounds.size.width, dy: -0.5 * bounds.size.height)
        layer0.position = center

        return layer0
    }

    func applyCorners(_ radius: CGFloat) {
        applyCorners(radius, topLeft: true, topRight: true, bottomRight: true, bottomLeft: true)
    }

    func applyCorners(_ radius: CGFloat, topLeft: Bool, topRight: Bool, bottomRight: Bool, bottomLeft: Bool) {

        var corners = UIRectCorner()
        var maskedCorners = CACornerMask()

        if topLeft {
            corners = corners.union(.topLeft)
            maskedCorners = maskedCorners.union(.layerMinXMinYCorner)
        }

        if topRight {
            corners = corners.union(.topRight)
            maskedCorners = maskedCorners.union(.layerMaxXMinYCorner)
        }

        if bottomRight {
            corners = corners.union(.bottomRight)
            maskedCorners = maskedCorners.union(.layerMaxXMaxYCorner)
        }

        if bottomLeft {
            corners = corners.union(.bottomLeft)
            maskedCorners = maskedCorners.union(.layerMinXMaxYCorner)
        }

        if #available(iOS 11.0, *) {
            layer.cornerRadius = radius
            layer.maskedCorners = maskedCorners
        } else {
            let maskPath = UIBezierPath(roundedRect: self.bounds,
                                        byRoundingCorners: corners,
                                        cornerRadii: CGSize(width: radius, height: radius))
            let layer1 = CAShapeLayer()
            layer1.path = maskPath.cgPath
            self.layer.mask = layer1
        }
    }

    func removeAllSubviews() {
        subviews.forEach {
            $0.removeFromSuperview()
        }
    }

    func allSubviewsOf<T: UIView>(type: T.Type) -> [T] {
        var all = [T]()

        func getSubview(view: UIView) {
            if let aView = view as? T {
                all.append(aView)
            }

            guard !view.subviews.isEmpty else { return }

            view.subviews.forEach {
                getSubview(view: $0)
            }
        }

        getSubview(view: self)
        return all
    }

    var selectedField: UITextField? {

        let totalTextFields = allFields(in: self)

        for textField in totalTextFields {
            if textField.isFirstResponder {
                return textField
            }
        }

        return nil
    }

    func allFields(in view: UIView) -> [UITextField] {

        var totalTextFields = [UITextField]()

        for subview in view.subviews as [UIView] {
            if let textField = subview as? UITextField {
                totalTextFields += [textField]
            } else {
                totalTextFields += allFields(in: subview)
            }
        }

        return totalTextFields
    }
}
