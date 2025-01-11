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
        print(downloadURL)
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
        print(downloadURL)
        return downloadURL
    }
    
    
}



enum StorageManagerError: Error {
    case fileManagerCreationError(Error)
    case couldntConvertToJpeg
    case couldntConvertToUIImage
}
