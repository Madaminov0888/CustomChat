//
//  MessageModel.swift
//  CustomChat
//
//  Created by Muhammadjon Madaminov on 29/02/24.
//

import Foundation
import UIKit


struct MessageModel: Identifiable, Codable, Equatable {
    static func == (lhs: MessageModel, rhs: MessageModel) -> Bool {
        lhs.id == rhs.id
    }
    
    let id: String
    let chat: String
    let sender: UserModel
    let content: String
    let dateSent: String
    let photoURL: String?
    var isItSeen: Bool
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case chat = "chat"
        case sender = "sender"
        case content = "content"
        case dateSent = "date_sent"
        case photoURL = "image_URL"
        case isItSeen = "is_it_seen"
    }
    
    mutating func messageState() {
        self.isItSeen = true
    }
}



struct MessageStateModel: Codable {
    let message: MessageModel
    let type: String
    
    enum CodingKeys: String, CodingKey {
        case type = "type"
        case message = "message"
    }
}


struct MessageImageTempModel: Identifiable {
    let id: String
    let image: UIImage
}
