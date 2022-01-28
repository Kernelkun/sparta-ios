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

    // MARK: - UI

    private var customImage: UIImageView!
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

        customImage.isHidden = true
        titleLabel.text = nil
        stopObservingAllBlendersEvents()
    }

    // MARK: - Public methods
    
    func apply(blenderCell: BlenderViewModel.BlenderCell) {
        self.blender = BlenderSyncManager.intance.fetchUpdatedState(for: blenderCell.blender)

        observeBlenders(blender)
        updateUI(for: self.blender)
    }

    // MARK: - Private methods

    private func setupUI() {

        selectedBackgroundView = UIView().then { $0.backgroundColor = .clear }
        tintColor = .controlTintActive

        customImage = UIImageView().then { imageView in

            imageView.image = UIImage(named: "ic_custom")

            contentView.addSubview(imageView) {
                $0.size.equalTo(20)
                $0.left.equalToSuperview().offset(4)
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
                $0.left.equalTo(customImage.snp.right).offset(6)
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
        customImage.isHidden = !blender.isCustom
    }
}

extension BlenderGradeCollectionViewCell: BlenderObserver {
    
    func blenderDidReceiveUpdates(_ blender: Blender) {
        onMainThread {
            self.updateUI(for: blender)
        }
    }
}
