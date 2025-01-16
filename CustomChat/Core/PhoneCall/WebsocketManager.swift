//
//  WebsocketManager.swift
//  CustomChat
//
//  Created by Muhammadjon Madaminov on 16/01/25.
//

import Foundation

class WebSocketManager: ObservableObject {
    private var webSocketTask: URLSessionWebSocketTask?
    private let url: URL

    init(userID: String) {
        self.url = URL(string: "ws://127.0.0.1:8000/ws/user_call/\(userID)")!
    }

    func connect() {
        let session = URLSession(configuration: .default)
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        receive()
    }

    func send(_ data: [String: Any]) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
            let message = URLSessionWebSocketTask.Message.data(jsonData)
            webSocketTask?.send(message) { error in
                if let error = error {
                    print("WebSocket send error: \(error)")
                }
            }
        } catch {
            print("Failed to encode message: \(error)")
        }
    }

    private func receive() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .data(let data):
                    self?.handleReceivedData(data)
                case .string(let text):
                    print("Received string: \(text)")
                @unknown default:
                    break
                }
            case .failure(let error):
                print("WebSocket receive error: \(error)")
            }
            self?.receive()  // Continue listening
        }
    }

    private func handleReceivedData(_ data: Data) {
        do {
            if let message = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                print("Received message: \(message)")
                // Handle offer, answer, or ICE candidates here
            }
        } catch {
            print("Failed to decode received data: \(error)")
        }
    }

    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }
}
