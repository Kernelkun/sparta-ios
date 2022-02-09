//
//  ScrollableHelpers.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 08.02.2022.
//

import UIKit

internal class Observable<Value>: NSObject {
  internal var observer: ((Value) -> Void)?
}

internal class KVObservable<Value>: Observable<Value> {
  private let keyPath: String
  private weak var object: AnyObject?
  private var observingContext = NSUUID().uuidString

  internal init(keyPath: String, object: AnyObject) {
    self.keyPath = keyPath
    self.object = object
    super.init()

    object.addObserver(self, forKeyPath: keyPath, options: [.new], context: &observingContext)
  }

  deinit {
    object?.removeObserver(self, forKeyPath: keyPath, context: &observingContext)
  }

  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    guard
      context == &observingContext,
      let newValue = change?[NSKeyValueChangeKey.newKey] as? Value
    else {
      return
    }

    observer?(newValue)
  }
}

internal class GestureStateObservable: Observable<UIGestureRecognizer.State> {
  private weak var gestureRecognizer: UIGestureRecognizer?

  internal init(gestureRecognizer: UIGestureRecognizer) {
    self.gestureRecognizer = gestureRecognizer
    super.init()

    gestureRecognizer.addTarget(self, action: #selector(self.handleEvent(_:)))
  }

  deinit {
    gestureRecognizer?.removeTarget(self, action: #selector(self.handleEvent(_:)))
  }

  @objc private func handleEvent(_ recognizer: UIGestureRecognizer) {
    observer?(recognizer.state)
  }
}

internal class PanGestureObservable: Observable<UIPanGestureRecognizer> {
  private weak var gestureRecognizer: UIPanGestureRecognizer?

  internal init(gestureRecognizer: UIPanGestureRecognizer) {
    self.gestureRecognizer = gestureRecognizer
    super.init()

    gestureRecognizer.addTarget(self, action: #selector(self.handleEvent(_:)))
  }

  deinit {
    gestureRecognizer?.removeTarget(self, action: #selector(self.handleEvent(_:)))
  }

  @objc private func handleEvent(_ recognizer: UIPanGestureRecognizer) {
    observer?(recognizer)
  }
}

internal protocol Scrollable: class {
  var contentOffset: CGPoint { get }
  var contentInset: UIEdgeInsets { get set }
  var scrollIndicatorInsets: UIEdgeInsets { get set }
  var contentSize: CGSize { get }
  var frame: CGRect { get }
  var contentSizeObservable: Observable<CGSize> { get }
  var contentOffsetObservable: Observable<CGPoint> { get }
  var panGestureStateObservable: Observable<UIGestureRecognizer.State> { get }
  var panGestureObservable: Observable<UIPanGestureRecognizer> { get }
  func updateContentOffset(_ contentOffset: CGPoint, animated: Bool)
}

// MARK: - UIScrollView + Scrollable
extension UIScrollView: Scrollable {
  var contentSizeObservable: Observable<CGSize> {
    return KVObservable<CGSize>(keyPath: #keyPath(UIScrollView.contentSize), object: self)
  }

  var contentOffsetObservable: Observable<CGPoint> {
    return KVObservable<CGPoint>(keyPath: #keyPath(UIScrollView.contentOffset), object: self)
  }

  var panGestureStateObservable: Observable<UIGestureRecognizer.State> {
    return GestureStateObservable(gestureRecognizer: panGestureRecognizer)
  }

    var panGestureObservable: Observable<UIPanGestureRecognizer> {
      return PanGestureObservable(gestureRecognizer: panGestureRecognizer)
    }

  func updateContentOffset(_ contentOffset: CGPoint, animated: Bool) {
    // Stops native deceleration.
    setContentOffset(self.contentOffset, animated: false)

    let animate = {
      self.contentOffset = contentOffset
    }

    guard animated else {
      animate()
      return
    }

    UIView.animate(withDuration: 0.25, delay: 0, options: [], animations: {
      animate()
    }, completion: nil)
  }
}

// MARK: - Scrollable + AirBar
internal extension Scrollable {
  func setBottomContentInsetToFillEmptySpace(heightDelta: CGFloat) {
    self.contentInset.bottom = max(0, frame.height - heightDelta - contentSize.height)
  }
}
