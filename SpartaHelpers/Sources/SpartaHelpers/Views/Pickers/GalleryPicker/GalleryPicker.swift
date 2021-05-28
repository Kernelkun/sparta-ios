//
//  GalleryPicker.swift
//  
//
//  Created by Yaroslav Babalich on 25.02.2021.
//

import UIKit
import Photos

open class GalleryPicker: NSObject {

    // MARK: - Public properties

    public typealias GalleryPickerClosure = (MediaCompletionInfo?) -> Void

    // MARK: - Variables properties

    private lazy var imagePicker = UIImagePickerController().then {
        $0.delegate = self
    }

    private var _uploadClosure: GalleryPickerClosure?

    // MARK: - Public methods

    public func requestVideoSourceAccess(completion: @escaping BoolClosure) {
        sendSourceVideoAuthorizationRequestIfNeed { [unowned self] isGranted in
            if isGranted {
                completion(true)
            } else {
                self.showNotAuthorizedPopup()
                completion(false)
            }
        }
    }

    public func uploadFromLibrary(mediaTypes: [MediaType],
                                  allowsEditing: Bool = false,
                                  controllerFromPresent: UIViewController? = nil,
                                  completion: @escaping GalleryPickerClosure) {

        sendPhotoLibraryAuthorizationRequestIfNeed { [unowned self] isAuthorized in
            guard isAuthorized == true else { self.showNotAuthorizedPopup(); return }

            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {

                self.imagePicker.mediaTypes = mediaTypes.map { $0.rawValue }
                self.imagePicker.sourceType = .photoLibrary
                self.imagePicker.allowsEditing = allowsEditing

                self._uploadClosure = completion

                if let controllerFromPresent = controllerFromPresent {
                    controllerFromPresent.present(self.imagePicker, animated: true, completion: nil)
                } else if let topController = UIViewController.topController {
                    topController.present(self.imagePicker, animated: true, completion: nil)
                }
            }
        }
    }

    public func uploadFromCamera(mediaTypes: [MediaType],
                                 allowsEditing: Bool = false,
                                 controllerFromPresent: UIViewController? = nil,
                                 completion: @escaping GalleryPickerClosure) {

        sendSourceVideoAuthorizationRequestIfNeed { [unowned self] isAuthorized in
            guard isAuthorized == true else { self.showNotAuthorizedPopup(); return }

            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {

                self.imagePicker.mediaTypes = mediaTypes.map { $0.rawValue }
                self.imagePicker.sourceType = .camera
                self.imagePicker.allowsEditing = allowsEditing
                self.imagePicker.cameraCaptureMode = .photo // selected mode

                self._uploadClosure = completion

                if let controllerFromPresent = controllerFromPresent {
                    self.imagePicker.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                    controllerFromPresent.present(self.imagePicker, animated: true, completion: nil)
                } else if let topController = UIViewController.topController {
                    topController.present(self.imagePicker, animated: true, completion: nil)
                }
            }
        }
    }

    public func showVariantsUIForUploadingPhotos(onOpenCamera: @escaping EmptyClosure,
                                                 onOpenLibrary: @escaping EmptyClosure,
                                                 onCancel: EmptyClosure? = nil) {

        let openCameraAction = AlertAction(title: "Open camera", style: .default)
        let openPhotoLibraryAction = AlertAction(title: "Open Photo Library", style: .default)
        let cancelAction = AlertAction(title: "Cancel", style: .cancel)

        let alert = Alert.alert(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.add(action: openCameraAction, completion: { _ in
            onOpenCamera()
        })
        alert.add(action: openPhotoLibraryAction, completion: { _ in
            onOpenLibrary()
        })
        alert.add(action: cancelAction, completion: { _ in
            onCancel?()
        })

        if let topController = UIViewController.topController {
            alert.show(in: topController)
        }
    }

    // MARK: - Video snapshot

    func getPreviewFromVideoFile(_ path: String) -> UIImage? {
        let vidURL = URL(fileURLWithPath: path)
        let asset = AVAsset(url: vidURL)

        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true

        let timestamp = CMTime(seconds: 1, preferredTimescale: 60)

        do {
            let imageRef = try generator.copyCGImage(at: timestamp, actualTime: nil)
            return UIImage(cgImage: imageRef)
        } catch let error as NSError {
            print("Image generation failed with error \(error)")
            return nil
        }
    }

    // MARK: - Private methods

    private func showNotAuthorizedPopup() {
        if let topController = UIViewController.topController {
            let okAction = AlertAction(title: "Ok", style: .default)
            let settingsAction = AlertAction(title: "Settings", style: .default)
            Alert.show(title: "Access denied",
                       message: "You denied access to media library. To share access with app please grand it from settings menu",
                       actions: [okAction, settingsAction],
                       in: topController) { selectedAction in

                if selectedAction == settingsAction {
                    guard let settingUrl = URL(string: UIApplication.openSettingsURLString) else { return }

                    UIApplication.shared.open(settingUrl, options: [:], completionHandler: nil)
                }
            }
        }
    }

    private func sendPhotoLibraryAuthorizationRequestIfNeed(completion: ((_ authorized: Bool) -> Void)?) {

        func isValidStatus(_ status: PHAuthorizationStatus) -> Bool {
            if #available(iOS 14, *) {
                return status == .authorized || status == .limited
            } else {
                return status == .authorized
            }
        }

        if isValidStatus(PHPhotoLibrary.authorizationStatus()) {
            completion?(true)
        } else {
            DispatchQueue.global().async {
                PHPhotoLibrary.requestAuthorization { status in
                    DispatchQueue.main.async(execute: {
                        completion?(isValidStatus(status))
                    })
                }
            }
        }
    }

    private func sendSourceVideoAuthorizationRequestIfNeed(completion: ((_ authorized: Bool) -> Void)?) {
        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
            completion?(true)
        } else {
            DispatchQueue.global().async {
                AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) -> Void in
                    DispatchQueue.main.async(execute: {
                        completion?(granted)
                    })
                })
            }
        }
    }

    private func parseInfo(_ info: [UIImagePickerController.InfoKey: Any]) -> MediaCompletionInfo? {
        guard let mediaType = info[.mediaType] as? String, let type = MediaType(rawValue: mediaType) else { return nil }

        let completionInfo = MediaCompletionInfo(type: type,
                                                 editedImage: info[.editedImage] as? UIImage,
                                                 originalImage: info[.originalImage] as? UIImage,
                                                 mediaUrl: info[.mediaURL] as? URL)

        return completionInfo
    }
}

extension GalleryPicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    public func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {

        imagePicker.dismiss(animated: true) { [unowned self] in
            self._uploadClosure?(self.parseInfo(info))
        }
    }

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePicker.dismiss(animated: true) { [unowned self] in
            self._uploadClosure?(nil)
        }
    }
}
