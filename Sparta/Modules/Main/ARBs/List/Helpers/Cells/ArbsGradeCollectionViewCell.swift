//
//  ArbsGradeCollectionViewCell.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 21.01.2021.
//

import UIKit
import SpartaHelpers
import NetworkingModels

class ArbsGradeCollectionViewCell: UICollectionViewCell {

    // MARK: - UI

    private var titleLabel: UILabel!
    private var firstDescriptionLabel: UILabel!
    private var secondDescriptionLabel: UILabel!
    private var bottomLine: UIView!

    // MARK: - Public accessors

    var arb: Arb!
    var indexPath: IndexPath!

    // MARK: - Private accessors

    private var _tapClosure: TypeClosure<Arb>?

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

        titleLabel.attributedText = nil
        stopObservingAllArbsEvents()
    }

    // MARK: - Public methods

    func onTap(completion: @escaping TypeClosure<Arb>) {
        _tapClosure = completion
    }

    func apply(arb: Arb) {
        self.arb = App.instance.arbsSyncManager.fetchUpdatedState(for: arb)

        observeArbs(arb)
        setupUI(for: self.arb)
    }

    // MARK: - Private methods

    private func setupUI() {

        tintColor = .controlTintActive

        _ = TappableView().then { view in

            titleLabel = UILabel().then { label in

                label.textAlignment = .left
                label.textColor = .white
                label.numberOfLines = 4
                label.isUserInteractionEnabled = true

                view.addSubview(label) {
                    $0.top.equalToSuperview().offset(10)
                    $0.left.right.equalToSuperview()
                }
            }

            view.backgroundColor = .clear

            view.onTap { [unowned self] _ in
                self._tapClosure?(self.arb)
            }

            contentView.addSubview(view) {
                $0.right.equalToSuperview()
                $0.left.equalToSuperview().offset(12)
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

    private func setupUI(for arb: Arb) {
        let gradeName = arb.grade.generateShortIfNeeded(maxSymbols: 30)
        let dischargePortName = arb.dischargePortName
        let freightType = arb.freightType
        let fullString: NSString = gradeName + "\n" + dischargePortName + "\n" + freightType as NSString

        let attributedString = NSMutableAttributedString(string: fullString as String)

        attributedString.addAttributes([NSAttributedString.Key.font: UIFont.main(weight: .regular, size: 13)],
                                       range: fullString.range(of: gradeName))

        attributedString.addAttributes([NSAttributedString.Key.font: UIFont.main(weight: .regular, size: 11)],
                                       range: fullString.range(of: dischargePortName))

        attributedString.addAttributes([NSAttributedString.Key.font: UIFont.main(weight: .regular, size: 11)],
                                       range: fullString.range(of: freightType))

        titleLabel.attributedText = attributedString
    }
}

extension ArbsGradeCollectionViewCell: ArbsObserver {

    func arbsDidReceiveResponse(for arb: Arb) {
        onMainThread {
            self.setupUI(for: arb)
        }
    }
}
