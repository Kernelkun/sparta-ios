//
//  ArbsPlaygroundPageViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 10.09.2021.
//

import UIKit
import NetworkingModels
import SpartaHelpers

protocol ArbsPlaygroundPageViewControllerDelegate: AnyObject {
    func arbPlaygroundPageResultDataViewDidChangeTGTValue(_ view: ArbPlaygroundResultDataView,
                                                          newValue: Double?)
    func arbPlaygroundPageInputDataViewDidChangeValue(_ view: ArbPlaygroundInputDataView,
                                                      newValue: ArbPlaygroundInputDataView.ObjectValue)
}

class ArbsPlaygroundPageViewController: BaseViewController {

    // MARK: - Public methods

    weak var delegate: ArbsPlaygroundPageViewControllerDelegate?

    // MARK: - Private properties

    private(set) var contentScrollView: UIScrollView!
    private(set) var inputDataView: ArbPlaygroundInputDataView!
    private(set) var resultDataView: ArbPlaygroundResultDataView!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    //
    // MARK: Keyboard Management

    var addedSize: CGSize = .zero

    override func updateUIForKeyboardPresented(_ presented: Bool, frame: CGRect) {
        super.updateUIForKeyboardPresented(presented, frame: frame)

        if presented && addedSize == .zero {
            var oldContentSize = contentScrollView.contentSize
            oldContentSize.height += frame.size.height

            addedSize.height = frame.size.height

            contentScrollView.contentSize = oldContentSize
        } else if !presented && addedSize != .zero {
            var oldContentSize = contentScrollView.contentSize
            oldContentSize.height -= addedSize.height
            addedSize = .zero

            contentScrollView.contentSize = oldContentSize
        }

        if let selectedTextField = view.selectedField {
            let newFrame = selectedTextField.convert(selectedTextField.frame, to: view)
            let maxFieldFrame = newFrame.maxY + 100

            if maxFieldFrame > frame.minY {
                contentScrollView.contentOffset = CGPoint(x: 0, y: maxFieldFrame - frame.minY)
            }
        }
    }

    // MARK: - Private methods

    private func setupUI() {
        contentScrollView = UIScrollView().then { scrollView in

            scrollView.showsVerticalScrollIndicator = false

            addSubview(scrollView) {
                $0.top.equalToSuperview()
                $0.left.bottom.right.equalToSuperview()
            }
        }

        let scrollViewContent = UIView().then { view in

            view.backgroundColor = .clear

            contentScrollView.addSubview(view) {
                $0.left.top.right.equalToSuperview()
                $0.bottom.lessThanOrEqualToSuperview().priority(.high)
                $0.centerX.equalToSuperview()
            }
        }

        inputDataView = ArbPlaygroundInputDataView().then { view in

            view.delegate = self

            scrollViewContent.addSubview(view) {
                $0.left.right.equalToSuperview()
                $0.top.equalToSuperview()
            }
        }

        // result block

        let resultView = UIView().then { view in

            view.backgroundColor = .plResultBlockBackground
            view.layer.cornerRadius = 10

            scrollViewContent.addSubview(view) {
                $0.top.equalTo(inputDataView.snp.bottom)
                $0.left.right.equalToSuperview().inset(16)
                $0.bottom.equalToSuperview().inset(8)
            }
        }

        resultDataView = ArbPlaygroundResultDataView().then { view in

            view.delegate = self

            resultView.addSubview(view) {
                $0.left.right.equalToSuperview().inset(12)
                $0.top.bottom.equalToSuperview()
            }
        }

        inputDataView.state = .inactive
        resultDataView.state = .inactive
    }
}

extension ArbsPlaygroundPageViewController: ArbPlaygroundResultDataViewDelegate {

    func arbPlaygroundResultDataViewDidChangeTGTValue(_ view: ArbPlaygroundResultDataView, newValue: Double?) {
        delegate?.arbPlaygroundPageResultDataViewDidChangeTGTValue(view, newValue: newValue)
    }
}

extension ArbsPlaygroundPageViewController: ArbPlaygroundInputDataViewDelegate {

    func arbPlaygroundInputDataViewDidTapInputTgt(_ view: ArbPlaygroundInputDataView) {
        resultDataView.becomeTgtFirstResponder()
    }

    func arbPlaygroundInputDataViewDidChangeValue(_ view: ArbPlaygroundInputDataView, newValue: ArbPlaygroundInputDataView.ObjectValue) {
        delegate?.arbPlaygroundPageInputDataViewDidChangeValue(view, newValue: newValue)
    }
}
