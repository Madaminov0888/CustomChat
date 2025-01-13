//
//  ChatRoomViewModel.swift
//  CustomChat
//
//  Created by Muhammadjon Madaminov on 16/03/24.
//

import Foundation
import SwiftUI
import Combine
import PhotosUI
import UIKit


@MainActor
final class ChatRoomViewModel: ObservableObject {
    
    @Published var messages: [MessageModel] = []
    @Published var messageText: String = ""
    
//    @Published var selectedUIImages: [UIImage] = []
    @Published var selectedMedia: [MessageMediaTempModel] = []
    //Image sending
    @Published var sendingImages: [MessageMediaTempModel] = []
    //video sending
    @Published var sendingVideos: [MessageMediaTempModel] = []
    
    
    @Published var previewImages: (image: Image,id: String)? = nil
    
    @Published var lastMessage: MessageModel?
    
    private var messageManager = MessagesManager()
    private var cancellable = Set<AnyCancellable>()
    
    
    func loadMessages(chat: ChatModel) async {
        do {
            self.messages = try await messageManager.getAllMessages(chatId: chat.id)
        } catch {
            print(error)
        }
    }
    
    func sendMessage(chat: ChatModel) async {
        do {
            try await messageManager.sendMessage(message: messageText, chatId: chat.id)
        } catch {
            print("error while sending")
            print(error)
        }
    }
    
    func sendMessageImage(chat: ChatModel, messageID: String, imageURL: String) async {
        do {
            try await messageManager.sendMessageImage(message: messageText, chatId: chat.id, image: imageURL, messageId: messageID)
        } catch {
            print("error while sending")
            print(error)
        }
    }
    
    
    func sendMessageState(message: MessageModel, chat: ChatModel) async {
        do {
            try await messageManager.sendMessageState(chatId: chat.id, messageId: message.id)
        } catch {
            print(error)
        }
    }
    
    
    
//    func getUIImages() async {
//        do {
//            await MainActor.run {
//                self.selectedUIImages.removeAll()
//            }
//            for image in selectedImages {
//                if let data = try await image.loadTransferable(type: Data.self),
//                    let uiimage = UIImage(data: data) {
//                    await MainActor.run {
//                        self.selectedUIImages.append(uiimage)
//                    }
//                }
//            }
//        } catch {
//            print(error)
//        }
//    }
    
    
    
    func recieveMessage(chat: ChatModel) async {
        do {
            while true {
                let message = try await messageManager.recieveMessage(chatId: chat.id)
                await MainActor.run {
                    if let changedMessageIndex = messages.firstIndex(where: { $0.id == message.id }) {
                        print("changing \(changedMessageIndex)")
                        messages[changedMessageIndex].isItSeen = true
                    } else {
                        messages.append(message)
                    }
                }
            }
        } catch {
            print("error while receiving")
            print(error)
        }
    }
    
    
    func getOtherUser(chat: ChatModel) -> UserModel? {
        do {
            let currentUser = try AuthManager.shared.getAuthedUser()
            if chat.chatUser.id == currentUser.id {
                return chat.chatCreator
            } else {
                return chat.chatUser
            }
        } catch {
            print(error)
        }
        return nil
    }
    
    func getMessagesWithIntervals() -> [(MessageModel, Bool)] {
        messages.enumerated().map { (index, message) -> (MessageModel, Bool) in
            if index == 0 {
                return (message, true)
            } else {
                let previousMessage = messages[index - 1]
                let showText = !message.dateSent.formatDateFromApi().timeIntervalSince(previousMessage.dateSent.formatDateFromApi()).isLess(than: 86400)
                return (message, showText)
            }
        }
    }
    
}




//MARK: PhotosPicker handler
extension ChatRoomViewModel {
    func handlePickerItems(_ pickerItems: [PhotosPickerItem]) async {
        await MainActor.run {
            self.selectedMedia.removeAll()
        }
        
        for item in pickerItems {
            do {
                if let transferableData = try await item.loadTransferable(type: Data.self) {
                    if item.supportedContentTypes.contains(where: { type in type.isSubtype(of: .audiovisualContent)}) {
                            // Save video locally and store the URL
                        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mp4")
                        try transferableData.write(to: tempURL)
                        
                        let mediaModel = MessageMediaTempModel(
                            id: UUID().uuidString,
                            type: .video,
                            content: .video(tempURL)
                        )
                        await MainActor.run {
                            selectedMedia.append(mediaModel)
                        }
                    } else {
                        if let uiImage = UIImage(data: transferableData) {
                            await MainActor.run {
                                selectedMedia.append(
                                    MessageMediaTempModel(id: UUID().uuidString, type: .image, content: .image(uiImage))
                                )
                            }
                        }
                    }
                }
            } catch {
                print("Error handling picker item: \(error.localizedDescription)")
            }
        }
    }
    
    
    func getImagesCount() -> Int {
        selectedMedia.filter { $0.type == .image }.count
    }
    
    func getVideosCount() -> Int {
        selectedMedia.filter { $0.type == .video }.count
    }
    
    func getImageVideo() {
        self.sendingImages = selectedMedia.filter { $0.type == .image }
        self.sendingVideos = selectedMedia.filter { $0.type == .video }
    }
}
