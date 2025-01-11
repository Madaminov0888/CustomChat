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
    @Published var selectedImages: [PhotosPickerItem] = []
    @Published var selectedUIImages: [UIImage] = []
    @Published var sendingImages: [MessageImageTempModel] = []
    
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
    
    
    
    func getUIImages() async {
        do {
            await MainActor.run {
                self.selectedUIImages.removeAll()
            }
            for image in selectedImages {
                if let data = try await image.loadTransferable(type: Data.self),
                    let uiimage = UIImage(data: data) {
                    await MainActor.run {
                        self.selectedUIImages.append(uiimage)
                    }
                }
            }
        } catch {
            print(error)
        }
    }
    
    
    
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
