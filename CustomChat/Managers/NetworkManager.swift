//
//  NetworkManager.swift
//  CustomChat
//
//  Created by Muhammadjon Madaminov on 29/02/24.
//

import Foundation

class NetworkManager {
    
    private let dbURL = "http://127.0.0.1:8000/api/"
    private let userURL = "user/"
    
    
    func getUserByID(uid: String) async throws -> UserModel {
        guard let url = URL(string: dbURL + userURL + uid) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        try handleResponse(response: response)
        let user = try JSONDecoder().decode(UserModel.self, from: data)
        return user
    }
    
    
    func handleResponse(response: URLResponse) throws {
        if let httpResponse = response as? HTTPURLResponse {
            guard httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 else {
                throw URLError(.badServerResponse)
            }
        } else {
            throw URLError(.badServerResponse)
        }
    }
    
    func getSearchUsers() async throws -> [UserModel] {
        guard let url = URL(string: dbURL + "users/") else { throw URLError(.badURL) }
        let (data, response) = try await URLSession.shared.data(from: url)
        try handleResponse(response: response)
        let users = try JSONDecoder().decode([UserModel].self, from: data)
        return users
    }
    
    
    func postUser(user: UserModel) async throws {
        guard let url = URL(string: dbURL + userURL) else {
            throw URLError(.badURL)
        }
        
        let data = try JSONEncoder().encode(user)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = data
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (_, response) = try await URLSession.shared.data(for: request)
        try handleResponse(response: response)
    }
    
    
    func putUserChanges(user: UserModel) async throws {
        // Ensure the URL is correctly formed
        guard let url = URL(string: dbURL + userURL) else {
            throw URLError(.badURL)
        }
        
        // Encode the user object into JSON data
        let data = try JSONEncoder().encode(user)
        if let jsonString = String(data: data, encoding: .utf8) {
            print("JSON Payload Sent to Server: \(jsonString)")
        }
        
        // Prepare the PUT request
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.httpBody = data
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Send the PUT request
        let (_, response) = try await URLSession.shared.data(for: request)
        try handleResponse(response: response)
    }
    
    
    
    
    func postChat(user: UserModel, creator: UserModel) async throws -> ChatModel {
        guard let url = URL(string: dbURL + "post_chat/\(creator.id)/\(user.id)") else {
            throw URLError(.badURL)
        }
        let request = URLRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        try handleResponse(response: response)
        let chat = try JSONDecoder().decode(ChatModel.self, from: data)
        return chat
    }
    
}
