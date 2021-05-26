//
//  BlenderGradeCollectionViewCell.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 02.12.2020.
//

import UIKit
import NetworkingModels
import SpartaHelpers

class BlenderGradeCollectionViewCell: UICollectionViewCell {

    // MARK: - Public properties

    private(set) var blender: Blender!

    // MARK: - Private accessors

    private var _tapFavouriteClosure: TypeClosure<Blender>?

    // MARK: - UI

    private var starButton: StarButton!
    private var titleLabel: UILabel!
    private var bottomLine: UIView!

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("BlenderGradeCollectionViewCell")
    }

    // MARK: - Lifecycle

    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)

        if let layoutAttributes = layoutAttributes as? GridViewLayoutAttributes {
            backgroundColor = layoutAttributes.backgroundColor
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        starButton.isActive = false
        titleLabel.text = nil
        stopObservingAllBlendersEvents()
    }

    // MARK: - Public methods
    
    func apply(blender: Blender) {
        self.blender = BlenderSyncManager.intance.fetchUpdatedState(for: blender)

        observeBlenders(blender)
        updateUI(for: self.blender)
    }

    func onToggleFavourite(completion: @escaping TypeClosure<Blender>) {
        _tapFavouriteClosure = completion
    }

    // MARK: - Private methods

    private func setupUI() {

        selectedBackgroundView = UIView().then { $0.backgroundColor = .clear }
        tintColor = .controlTintActive

        starButton = StarButton().then { button in

            button.clickableInset = -10

            button.onTap { [unowned self] button in
                guard let button = button as? StarButton else { return }

                button.isActive.toggle()
                self._tapFavouriteClosure?(self.blender)
            }

            button.backgroundColor = .clear

            contentView.addSubview(button) {
                $0.size.equalTo(19)
                $0.left.equalToSuperview().offset(14)
                $0.centerY.equalToSuperview()
            }
        }

        _ = TappableView().then { view in

            titleLabel = UILabel().then { label in

                label.textAlignment = .left
                label.textColor = .white
                label.numberOfLines = 2
                label.isUserInteractionEnabled = true
                label.font = .main(weight: .regular, size: 14)

                view.addSubview(label) {
                    $0.edges.equalToSuperview()
                }
            }

            view.backgroundColor = .clear

            contentView.addSubview(view) {
                $0.right.equalToSuperview()
                $0.left.equalTo(starButton.snp.right).offset(12)
                $0.top.equalToSuperview()
                $0.bottom.equalToSuperview().inset(CGFloat.separatorWidth)
            }
        }

        bottomLine = UIView().then { view in

            view.backgroundColor = UIGridViewConstants.tableSeparatorLineColor

            contentView.addSubview(view) {
                $0.height.equalTo(CGFloat.separatorWidth)
                $0.left.right.bottom.equalToSuperview()
            }
        }
    }

    private func updateUI(for blender: Blender) {
        titleLabel.text = blender.grade
        starButton.isActive = blender.isFavourite
    }
}

extension BlenderGradeCollectionViewCell: BlenderObserver {
    
    func blenderDidReceiveUpdates(_ blender: Blender) {
        onMainThread {
            self.updateUI(for: blender)
        }
    }
}
