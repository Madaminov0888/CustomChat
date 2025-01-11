//
//  ChatManager.swift
//  CustomChat
//
//  Created by Muhammadjon Madaminov on 02/03/24.
//

import Foundation
import Combine

enum NetworkingError: LocalizedError {
    case badURLResponse
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .badURLResponse: return "[] Bad response from URL."
        case .unknown: return "[] Unknown error"
        }
    }
}


final class ChatManager {
    
    private let dbURL = "http://127.0.0.1:8000/api/"
    private let usersChat = "chats/user/"
    
    @Published var publisher: [ChatModel] = []
    private var cancellables = Set<AnyCancellable>()
    
    
    
    
    func getChats(uid: String) async throws -> [ChatModel] {
        guard let url = URL(string: dbURL + usersChat + uid) else {
            print("problem is in here!!!")
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        return try responseHandler(data: data, response: response)
    }
    
    func responseHandler(data: Data, response: URLResponse) throws -> [ChatModel] {
        guard
            let response1 = response as? HTTPURLResponse,
            response1.statusCode >= 200 && response1.statusCode < 300,
            let chats = try? JSONDecoder().decode([ChatModel].self, from: data) else {
            throw URLError(.badServerResponse)
        }
        return chats
    }
    
    
    
    func recieveChatUpdate(uid: String) async throws -> MessageModel {
        guard let url = URL(string: "ws://127.0.0.1:8000/ws/user/" + uid) else {
            throw URLError(.badURL)
        }
        
        let ws = URLSession.shared.webSocketTask(with: url)
        
        ws.resume()
        
        return try await setReceiveHandler(ws: ws)
    }
    
    func setReceiveHandler(ws: URLSessionWebSocketTask) async throws -> MessageModel {
        guard ws.closeCode == .invalid else {
            throw URLError(.cancelled)
        }
        
        let message = try await ws.receive()
        
        switch message {
        case let .data(data):
            print("unknown data: \(data)")
            throw URLError(.unknown)
        case .string(let string):
            if let jsonData = string.data(using: .utf8) {
                let messageModel = try JSONDecoder().decode(MessageModel.self, from: jsonData)
                return messageModel
            } else {
                print("unknown")
                throw URLError(.unknown)
            }
        @unknown default:
            return try await setReceiveHandler(ws: ws)
        }
    }
    
    
    
    
    func recieveWebSocketMessages(uid: String) async throws {
        let maxRetries = 5
        var retryCount = 0
        
        while retryCount < maxRetries {
            do {
                guard let url = URL(string: "ws://127.0.0.1:8000/ws/chats/") else {
                    throw URLError(.badServerResponse)
                }
                
                let ws = URLSession.shared.webSocketTask(with: url)
                ws.resume()
                
                try await sendMessage(ws: ws, uid: uid)
                try await recieveMessage(ws: ws)
                
                retryCount = 0 // Reset retry count on success
            } catch {
                print("WebSocket connection failed: \(error)")
                retryCount += 1
                if retryCount >= maxRetries {
                    print("Max WebSocket retry limit reached. Stopping connection attempts.")
                    break
                }
            }
            
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        }
    }

    
    func sendMessage(ws: URLSessionWebSocketTask, uid: String) async throws {
        let requestData: [String: Any] = [
            "type": "users_chats",
            "chat_creator_id" : uid,
        ]
        if let jsonData = JSONDecoder().convertDictionaryToJSON(requestData) {
            try await ws.send(URLSessionWebSocketTask.Message.string(jsonData))
        } else {
            throw URLError(.cannotDecodeRawData)
        }
    }
    
    func recieveMessage(ws: URLSessionWebSocketTask) async throws {
        let response = try await ws.receive()
        switch response {
        case .data(let data):
            print("data: \(data)")
        case .string(let string):
            if let jsonData = string.data(using: .utf8) {
                let chats = try JSONDecoder().decode([ChatModel].self, from: jsonData)
                await MainActor.run {
                    self.publisher = chats
                }
            }
        @unknown default:
            throw URLError(.cannotDecodeRawData)
        }
    }
    
}

