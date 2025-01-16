//
//  MessagesManager.swift
//  CustomChat
//
//  Created by Muhammadjon Madaminov on 16/03/24.
//

import Foundation
import SwiftUI
import Combine


final class MessagesManager {
    
    let websocketUrl: String = "ws://127.0.0.1:8000/ws/messages/"
    private let messagesURL = "http://127.0.0.1:8000/api/messages/chat/"
    
    
    func getAllMessages(chatId: String) async throws -> [MessageModel] {
        guard let url = URL(string: messagesURL + chatId) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        return try responseHandler(data: data, response: response)
        
    }
    
    
    func responseHandler(data: Data, response: URLResponse) throws -> [MessageModel] {
        guard
            let response1 = response as? HTTPURLResponse,
            response1.statusCode >= 200 && response1.statusCode < 300,
            let messages = try? JSONDecoder().decode([MessageModel].self, from: data) else {
            throw URLError(.badServerResponse)
        }
        return messages
    }
    
    
    func messageResponseHandler(data: Data, response: URLResponse) throws -> MessageModel {
        guard
            let response1 = response as? HTTPURLResponse,
            response1.statusCode >= 200 && response1.statusCode < 300,
            let message = try? JSONDecoder().decode(MessageModel.self, from: data) else {
            throw URLError(.badServerResponse)
        }
        return message
    }
    
    
    func recieveMessage(chatId: String) async throws -> MessageModel {
        guard let url = URL(string: websocketUrl + chatId) else {
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
            return try await EncodingAndGettingMessage(string: string)
        @unknown default:
            return try await setReceiveHandler(ws: ws)
        }
    }
    
    
    func sendMessage(message: String, chatId: String) async throws {
        guard let url = URL(string: websocketUrl + chatId) else {
            throw URLError(.badURL)
        }
        
        let ws = URLSession.shared.webSocketTask(with: url)
        
        ws.resume()
        
        let messageId = UUID().uuidString
        
        let request: [String: Any] = [
            "type": "message",
            "sender": try AuthManager.shared.getAuthedUser().authId ?? "",
            "message": message,
            "message_id":messageId
        ]
        
        
        if let jsonData = JSONDecoder().convertDictionaryToJSON(request) {
            try await ws.send(URLSessionWebSocketTask.Message.string(jsonData))
        } else {
            throw URLError(.cannotDecodeRawData)
        }
    }
    
    
    func sendMessageImage(message: String, chatId: String, image: String, messageId: String) async throws {
        guard let url = URL(string: websocketUrl + chatId) else {
            throw URLError(.badURL)
        }
        
        let ws = URLSession.shared.webSocketTask(with: url)
        
        ws.resume()
        
        
        let request: [String: Any] = [
            "type": "message_with_image",
            "sender": try AuthManager.shared.getAuthedUser().authId ?? "",
            "message": message,
            "message_id":messageId,
            "image_url": image,
        ]
        
        
        if let jsonData = JSONDecoder().convertDictionaryToJSON(request) {
            try await ws.send(URLSessionWebSocketTask.Message.string(jsonData))
        } else {
            throw URLError(.cannotDecodeRawData)
        }
    }
    
    
    func sendMessageAudio(message: String, chatId: String, audioURL: String, messageId: String) async throws {
        guard let url = URL(string: websocketUrl + chatId) else {
            throw URLError(.badURL)
        }
        
        let ws = URLSession.shared.webSocketTask(with: url)
        
        ws.resume()
        
        
        let request: [String: Any] = [
            "type": "message_with_audio",
            "sender": try AuthManager.shared.getAuthedUser().authId ?? "",
            "message": message,
            "message_id":messageId,
            "audio_url": audioURL,
        ]
        
        
        if let jsonData = JSONDecoder().convertDictionaryToJSON(request) {
            try await ws.send(URLSessionWebSocketTask.Message.string(jsonData))
        } else {
            throw URLError(.cannotDecodeRawData)
        }
    }
    
    
    func sendMessageVideo(message: String, chatId: String, video: String, messageId: String) async throws {
        guard let url = URL(string: websocketUrl + chatId) else {
            throw URLError(.badURL)
        }
        
        let ws = URLSession.shared.webSocketTask(with: url)
        
        ws.resume()
        
        
        let request: [String: Any] = [
            "type": "message_with_video",
            "sender": try AuthManager.shared.getAuthedUser().authId ?? "",
            "message": message,
            "message_id":messageId,
            "video_url": video,
        ]
        
        
        if let jsonData = JSONDecoder().convertDictionaryToJSON(request) {
            try await ws.send(URLSessionWebSocketTask.Message.string(jsonData))
        } else {
            throw URLError(.cannotDecodeRawData)
        }
    }
    
    
    func sendMessageState(chatId: String, messageId: String) async throws {
        guard let url = URL(string: websocketUrl + chatId) else {
            throw URLError(.badURL)
        }
        
        let ws = URLSession.shared.webSocketTask(with: url)
        
        ws.resume()
        
        let request: [String: Any] = [
            "type": "message_state",
            "sender": try AuthManager.shared.getAuthedUser().authId ?? "",
            "message_id":messageId
        ]
        
        
        if let jsonData = JSONDecoder().convertDictionaryToJSON(request) {
            try await ws.send(URLSessionWebSocketTask.Message.string(jsonData))
        } else {
            throw URLError(.cannotDecodeRawData)
        }
    }
    
}



extension MessagesManager {
    //Additional functions
    func EncodingAndGettingMessage(string: String) async throws -> MessageModel {
        do {
            if let jsonData = string.data(using: .utf8) {
                let messageModel = try JSONDecoder().decode(MessageModel.self, from: jsonData)
                print("sent message : \(messageModel.content) \(messageModel.isItSeen)")
                return messageModel
            } else {
                print("unknown")
                throw URLError(.unknown)
            }
        } catch {
            print(error.localizedDescription)
            throw URLError(.badServerResponse)
        }
    }
}
