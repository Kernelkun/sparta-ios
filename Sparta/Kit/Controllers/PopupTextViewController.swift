//
//  PopupTextViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 29.11.2020.
//

import UIKit

final class PopupTextViewController: UIViewController {

    //
    // MARK: - Public Accessors

    let text: String

    //
    // MARK: - Popup UI Constants

    private let textMargins: CGFloat = 10

    private let paragraphStyle = NSMutableParagraphStyle().then {
        $0.lineSpacing = 6
    }

    private var contentSize: CGSize {

        let maxWidth = UIScreen.main.bounds.width - 30

        var retVal = text.size(constrained: maxWidth, attributes: [.paragraphStyle: paragraphStyle])
        retVal.width += textMargins * 2
        retVal.height += textMargins * 2

        return retVal
    }

    //
    // MARK: - UI References

    private var contentLabel: UILabel!

    //
    // MARK: - View Lifecycle

    init(text: String) {
        self.text = text
        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .popover
        modalTransitionStyle = .crossDissolve

        preferredContentSize = contentSize
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = UIView(frame: CGRect(origin: .zero, size: contentSize))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTapGesture))
        tapRecognizer.cancelsTouchesInView = false

        view.addGestureRecognizer(tapRecognizer)
    }

    private func setupUI() {

        contentLabel = UILabel().then { v in
            v.font = .systemFont(ofSize: 11, weight: .regular)
            v.textColor = .primaryText

            v.numberOfLines = 0
            v.textAlignment = .left
            v.attributedText = NSAttributedString(string: text, attributes: [.paragraphStyle: paragraphStyle])

            addSubview(v) { make in
                make.topMargin.bottomMargin.equalToSuperview().inset(textMargins)
                make.leading.trailing.equalToSuperview().inset(textMargins)
            }
        }
    }

    @objc func onTapGesture() {
        dismiss(animated: true, completion: nil)
    }
}

//
// MARK: - Popover Presentation

extension PopupTextViewController {

    func popup(from sourceRect: CGRect, in viewController: UIViewController, animated: Bool = true) {

        popoverPresentationController?.permittedArrowDirections = [.down, .up]
        popoverPresentationController?.sourceView = viewController.view
        popoverPresentationController?.sourceRect = sourceRect
        popoverPresentationController?.delegate = self

        viewController.present(self, animated: animated, completion: nil)
    }
}

//
// MARK: - UIPopoverPresentationControllerDelegate Implementation

extension PopupTextViewController: UIPopoverPresentationControllerDelegate {

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    func popoverPresentationControllerDidDismissPopover(
        _ popoverPresentationController: UIPopoverPresentationController) {
    }

    func popoverPresentationControllerShouldDismissPopover(
        _ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return true
    }
}
