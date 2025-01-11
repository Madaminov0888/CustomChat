//
//  ChatViewModel.swift
//  CustomChat
//
//  Created by Muhammadjon Madaminov on 01/03/24.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class ChatViewModel: ObservableObject {
    
    @Published private(set) var chats: [ChatModel] = []
    @Published private(set) var currentUser: UserModel? = nil
    @Published var notifications: [MessageModel] = []
    @Published var searchUsers: [UserModel] = []
    @Published var allUsersList: [UserModel] = []
    @Published var searchText: String = ""
    @Published var chatSearchText: String = ""
    
    @Published var showUsersSheet: Bool = false
    
    private let chatManager = ChatManager()
    private var cancellables = Set<AnyCancellable>()
    private let networkManager = NetworkManager()
    
    
    
    func connectionHandler() async {
        var retryCount = 0
        let maxRetries = 10
        do {
            while true {
            
                print("trying")
                try await loadMessages()
                try await loadUserChats()
                retryCount = 0 // Reset retry count on success
            
                try await Task.sleep(nanoseconds: 1_000_000_000) // 2 seconds
            }
        } catch {
            print("Failed to load data: \(error)")
            retryCount += 1
            if retryCount >= maxRetries {
                print("Max retry limit reached. Stopping task.")
            }
        }
        
    }
    
    
    func loadUserChats() async throws {
        self.chats = try await chatManager.getChats(uid: try AuthManager.shared.getAuthedUser().id)
    }
    
    
    func loadMessages() async throws {
        self.notifications.append(try await chatManager.recieveChatUpdate(uid: try AuthManager.shared.getAuthedUser().id))
    }
    
    
    func countUnseenMessages(messages: [MessageModel]) -> String {
        var unseenCount = 0
        var messages2: [MessageModel] = messages
        messages2.reverse()
        
        for message in messages2 {
            if !message.isItSeen && (message.sender.id != (try? AuthManager.shared.getAuthedUser().id)) {
                unseenCount += 1
            } else {
                break
            }
        }
        
        return String(unseenCount)
    }
    
    
    func getLastMessage(chat: ChatModel) -> MessageModel? {
        let messages = chat.chat_messages
        if messages.count > 0 {
            return messages.last
        } else {
            return nil
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
    
    
    func getSearchUsers() {
        Task {
            do {
                let users = try await networkManager.getSearchUsers()
                await MainActor.run {
                    self.allUsersList = users
                    self.searchUsers = users
                }
            } catch {
                print(error)
            }
        }
    }
    
    func postChat(user: UserModel) async -> ChatModel? {
        do {
            let chat = try await networkManager.postChat(user: user, creator: AuthManager.shared.getAuthedUser())
            return chat
        } catch {
            print(error)
            return nil
        }
    }
}
