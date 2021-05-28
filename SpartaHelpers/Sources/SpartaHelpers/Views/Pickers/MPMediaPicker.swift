//
//  MPMediaPicker.swift
//  
//
//  Created by Yaroslav Babalich on 01.02.2021.
//

import MediaPlayer
import StoreKit

public protocol MPMediaPickerDelegate: class {
    func mpMediaPickerDidPick(_ items: [MPMediaItem])
}

open class MPMediaPicker: NSObject {

    // MARK: - Private properties

    fileprivate var _chooseClosure: TypeClosure<[MPMediaItem]>?

    let systemMusicPlayer: MPMusicPlayerController & MPSystemMusicPlayerController

    // MARK: - Initializers

    public override init() {
        systemMusicPlayer = MPMusicPlayerController.systemMusicPlayer
        systemMusicPlayer.setQueue(with: ["1108845248"])
    }

    // MARK: - Public methods

    public func checkAccess(completion: @escaping TypeClosure<Bool>) {
        guard SKCloudServiceController.authorizationStatus() != .authorized else {
            completion(true)
            return
        }

        SKCloudServiceController.requestAuthorization { status in
            switch status {
            case .authorized:
                completion(true)

            @unknown default:
                completion(false)
            }
        }
    }

    public func present(from controller: UIViewController, completion: @escaping TypeClosure<[MPMediaItem]>) {
        checkIfAppleMusicInstalled { [unowned self] isInstalled in
            guard isInstalled else {
                Alert.showOk(title: "Apple Music isn't installed", message: nil, show: nil, completion: nil)
                completion([])
                return
            }

            _chooseClosure = completion
            presentMPController(from: controller)
        }
    }

    // MARK: - Private methods

    private func checkIfAppleMusicInstalled(completion: @escaping TypeClosure<Bool>) {
        systemMusicPlayer.prepareToPlay { error in
            completion(error == nil)
        }
    }

    private func presentMPController(from controller: UIViewController) {
        let mpController = MPMediaPickerController(mediaTypes: .music)
        mpController.allowsPickingMultipleItems = false
        mpController.showsCloudItems = false
        mpController.showsItemsWithProtectedAssets = false
        mpController.popoverPresentationController?.sourceView = controller.view
        mpController.delegate = self
        controller.present(mpController, animated: true)
    }
}

extension MPMediaPicker: MPMediaPickerControllerDelegate {

    public func mediaPicker(_ mediaPicker: MPMediaPickerController,
                            didPickMediaItems mediaItemCollection: MPMediaItemCollection) {

        _chooseClosure?(mediaItemCollection.items)
        mediaPicker.dismiss(animated: true)
    }

    public func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        mediaPicker.dismiss(animated: true)
        _chooseClosure?([])
    }
}
