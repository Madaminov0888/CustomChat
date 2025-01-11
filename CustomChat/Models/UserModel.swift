//
//  UserModel.swift
//  CustomChat
//
//  Created by Muhammadjon Madaminov on 29/02/24.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseAuth



struct UserModel: Codable, Identifiable {
    let id: String
    let name: String?
    let userName: String?
    let authId: String?
    let phoneNumber: String?
    let email: String?
    let isAnonymous: Bool
    let photoUrl: String?
    let dateCreated: String?
    let isPremium: Bool
    
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case userName = "user_name"
        case authId = "auth_id"
        case phoneNumber = "phone_number"
        case email = "email"
        case isAnonymous = "is_anonymous"
        case photoUrl = "photo_url"
        case dateCreated = "date_created"
        case isPremium = "is_premium"
    }
    
    init(id: String, name: String?, userName: String?, authId: String?, phoneNumber: String?, email: String?, isAnonymous: Bool, photoUrl: String?, dateCreated: String?, isPremium: Bool) {
        self.id = id
        self.name = name
        self.userName = userName
        self.authId = authId
        self.phoneNumber = phoneNumber
        self.email = email
        self.isAnonymous = isAnonymous
        self.photoUrl = photoUrl
        self.dateCreated = dateCreated
        self.isPremium = isPremium
    }
    
    init(user: User) {
        self.id = user.uid
        self.authId = user.uid
        self.name = user.displayName
        self.userName = nil
        self.phoneNumber = user.phoneNumber
        self.email = user.email
        self.isAnonymous = false
        self.photoUrl = user.photoURL?.absoluteString
        self.dateCreated = nil
        self.isPremium = false
    }
    
    init(user: User, name: String, userName: String, photoUrl: String?) {
        self.id = user.uid
        self.authId = user.uid
        self.name = name
        self.userName = userName
        self.phoneNumber = user.phoneNumber
        self.email = user.email
        self.isAnonymous = false
        self.photoUrl = photoUrl ?? user.photoURL?.absoluteString
        self.dateCreated = nil
        self.isPremium = false
    }
    
}
