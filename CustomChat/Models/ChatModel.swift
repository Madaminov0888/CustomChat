//
//  ChatModel.swift
//  CustomChat
//
//  Created by Muhammadjon Madaminov on 29/02/24.
//

import Foundation
import SwiftUI


struct ChatModel: Identifiable, Codable {
    let id: String
    let chatCreator: UserModel
    let chatUser: UserModel
    let chat_messages: [MessageModel]
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case chatCreator = "chat_creator"
        case chatUser = "chat_user"
        case chat_messages = "chat_messages"
    }
}
