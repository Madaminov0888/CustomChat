//
//  StorageManager.swift
//  CustomChat
//
//  Created by Muhammadjon Madaminov on 07/01/25.
//

import Foundation
import SwiftUI
import FirebaseStorage
import UIKit
import FirebaseStorageCombineSwift
import Firebase


final class StorageManager {
    private let storage = Storage.storage().reference()
    
    private var usersReference: StorageReference {
        storage.child("users")
    }
    
    private var chatsReference: StorageReference {
        storage.child("chats")
    }
    
    public func uploadUserPhoto(image: UIImage, progress: @escaping (Progress?) -> Void) async throws -> URL {
        let reference = usersReference.child("\(UUID().uuidString).jpeg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        guard let data = image.jpegData(compressionQuality: 0.9) else {
            throw StorageManagerError.couldntConvertToJpeg
        }
        let _ = try await reference.putDataAsync(data, metadata: metadata, onProgress: progress)
        let downloadURL = try await reference.downloadURL()
        return downloadURL
    }
    
    public func uploadMessagePhoto(image: UIImage, chatId: String, messageId: String ,progress: @escaping (Progress?) -> Void) async throws -> URL {
        let reference = chatsReference.child("\(chatId)/\(messageId).jpeg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        guard let data = image.jpegData(compressionQuality: 0.5) else {
            throw StorageManagerError.couldntConvertToJpeg
        }
        let _ = try await reference.putDataAsync(data, metadata: metadata, onProgress: progress)
        let downloadURL = try await reference.downloadURL()
        return downloadURL
    }
    
    public func uploadMessageVideo(videoURL: URL, chatId: String, messageId: String, progress: @escaping (Progress?) -> Void) async throws -> URL {
        // Reference to Firebase Storage location
        let reference = chatsReference.child("\(chatId)/\(messageId).mp4")
        let metadata = StorageMetadata()
        metadata.contentType = "video/mp4"

        // Check if the video file exists at the given URL
        guard FileManager.default.fileExists(atPath: videoURL.path) else {
            throw StorageManagerError.couldntFindFile
        }

        // Read video file data
        let videoData = try Data(contentsOf: videoURL)

        // Upload the video data
        let _ = try await reference.putDataAsync(videoData, metadata: metadata, onProgress: progress)

        // Get the download URL
        let downloadURL = try await reference.downloadURL()
        print("Video uploaded. Download URL: \(downloadURL)")
        return downloadURL
    }
    
    
}



enum StorageManagerError: Error {
    case fileManagerCreationError(Error)
    case couldntConvertToJpeg
    case couldntConvertToUIImage
    case couldntFindFile
}
