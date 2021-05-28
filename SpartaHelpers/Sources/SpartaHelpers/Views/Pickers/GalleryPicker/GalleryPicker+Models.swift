//
//  GalleryPicker+Models.swift
//  
//
//  Created by Yaroslav Babalich on 25.02.2021.
//

import UIKit

extension GalleryPicker {

    public enum MediaType: String {
        case image = "public.image"
        case video = "public.movie"
    }

    public struct MediaCompletionInfo {

        // MARK: - Variables public

        public let type: MediaType
        public let editedImage: UIImage?
        public let originalImage: UIImage?
        public let mediaUrl: URL?
    }
}
