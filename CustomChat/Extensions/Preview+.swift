//
//  Preview+.swift
//  CustomChat
//
//  Created by Muhammadjon Madaminov on 13/03/24.
//

import Foundation
import SwiftUI

extension Preview {
    
    static let userModel: UserModel = UserModel(id: "Psadu5tRXdb1LQHbRtFKp1LRiDZ2", name: "Madaminov Muhammadjon", userName: nil, authId: "Psadu5tRXdb1LQHbRtFKp1LRiDZ2", phoneNumber: nil, email: "madaminov0888@gmail.com", isAnonymous: false, photoUrl: "https://lh3.googleusercontent.com/a/ACg8ocJEKmlfNUBjub0kOQZj0zovURT5JtjNDrfY9yKAtJcx=s96-c", dateCreated: nil, isPremium: false)
    static let userModel2: UserModel = UserModel(id: "e95802fe-6b5f-4055-a416-d7b9e8061432", name: "Otanazar", userName: "otanazar", authId: nil, phoneNumber: nil, email: nil, isAnonymous: false, photoUrl: nil, dateCreated: nil, isPremium: false)
    
    static let message: MessageModel = MessageModel(id: "82ddc843-bf21-4194-a71e-9778d5b4e906", chat: "de9da4e6-9641-4b3f-a62a-4e0281d1216d", sender: userModel, content: "Na gaple indi bugun", dateSent: "2024-03-11T14:16:39.874861+05:00", photoURL: nil, videoURL: nil, isItSeen: false)
    
    static let devChatModel: ChatModel = ChatModel(id: "de9da4e6-9641-4b3f-a62a-4e0281d1216d", chatCreator: userModel, chatUser: userModel2, chat_messages: [message])
    
}
