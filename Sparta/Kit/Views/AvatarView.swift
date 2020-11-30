//
//  AvatarView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 27.11.2020.
//

import UIKit
import Nuke
import SpartaHelpers

class AvatarView: UIButton {

    enum Corners {
        case `default`
        case fullyRounded
        case rounded(CGFloat)
    }

    enum Content {
        case image(UIImage)
        case defaultUserPlaceholder
    }

    //
    // MARK: - Public Accessors

    var corners: Corners = .default {
        didSet {
            oldFrame = .zero
            setNeedsLayout()
        }
    }

    var content: Content? {
        didSet {

            guard let content = content else {
                setImage(nil, for: .normal)
                return
            }

            subviews
                .filter { $0 is AvatarView }
                .forEach { $0.removeFromSuperview() }

            switch content {
//            case .user(let user) where user.image?.nullable != nil:
//                loadImage(user.image!.forcedURL)
//
//            case .coupon(let coupon) where coupon.image?.nullable != nil:
//                loadImage(coupon.image!.forcedURL)
//
//            case .merchant(let merchant) where merchant.image?.nullable != nil:
//                loadImage(merchant.image!.forcedURL)
//
//            case .message(let message) where message.avatar != nil:
//                loadImage(message.avatar!.forcedURL)

            case .image(let image):
                setImage(image, for: .normal)


            case .defaultUserPlaceholder:
                setImage(UIImage(named: "ic_image_placeholder"), for: .normal)

//            case .user, .coupon, .merchant, .message:
//                setImage(UIImage(named: "ic_image_placeholder"), for: .normal)
            }
        }
    }

    var isPhotoButtonEnabled: Bool = false {
        didSet {
            updateUI()
        }
    }

    func onTap(completion: @escaping EmptyClosure) {

        tapClosure = completion
        isUserInteractionEnabled = true
        addTarget(self, action: #selector(onTapEvent(_:)), for: .touchUpInside)
    }

    //
    // MARK: - Private Stuff

    private var oldFrame: CGRect = .zero
    private var tapClosure: EmptyClosure?
    private var photoButton: UIImageView!

    //
    // MARK: - View Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if frame != oldFrame {

            switch corners {
            case .default: applyCorners(0)
            case .fullyRounded: applyCorners(bounds.height / 2)
            case .rounded(let radius): applyCorners(radius)
            }

            oldFrame = frame
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        content = nil ?? content
    }

    //
    // MARK: - Private Methods

    private func setupUI() {

        isUserInteractionEnabled = false
        clipsToBounds = true
//        backgroundColor = .barBackground

        contentHorizontalAlignment = .fill
        contentVerticalAlignment = .fill

        updateUI()
    }

    private func updateUI() {
        /*if isPhotoButtonEnabled {
            if photoButton?.superview == nil {
                photoButton = UIImageView().then { photoButton in

                    let configuration = UIImage.SymbolConfiguration(pointSize: 19)
                    photoButton.image = UIImage(systemName: "camera.fill", withConfiguration: configuration)
                    photoButton.tintColor = .controlTintActive

                    addSubview(photoButton) {
                        $0.centerX.equalToSuperview()
                        $0.bottom.equalToSuperview().inset(8)
                    }
                }
            }

            photoButton?.alpha = 1
        } else {
            photoButton?.alpha = 0
        }*/
    }

    //

    private func clearImage() {
        setImage(nil, for: .normal)
    }

    private func loadImage(_ url: URL) {

        Nuke.loadImage(with: url, into: self)

        imageView?.contentMode = .scaleAspectFill
    }

    @objc private func onTapEvent(_ sender: UIButton) {
        tapClosure?()
    }
}

extension AvatarView: Nuke_ImageDisplaying {

    func nuke_display(image: PlatformImage?) {
        setImage(image, for: .normal)
    }
}
