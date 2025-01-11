//
//  AuthManager.swift
//  CustomChat
//
//  Created by Muhammadjon Madaminov on 01/03/24.
//

import Foundation
import Firebase
import FirebaseAuth



final class AuthManager {
    
    static let shared = AuthManager()
    private init() { }
    
    func deleteUser() async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.userAuthenticationRequired)
        }
        
        try await user.delete()
    }
    
    
    @discardableResult
    func getAuthedUser() throws -> UserModel {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badURL)
        }
        return UserModel(user: user)
    }
    
    func logOut() throws {
        try Auth.auth().signOut()
    }
    
    
    //sign in-up with google
    func signInWithCredential(credential: AuthCredential) async throws -> UserModel {
        let data = try await Auth.auth().signIn(with: credential)
        return UserModel(user: data.user)
    }
    
    
    @discardableResult
    func signInWithGoogle(tokens: TokensModel) async throws -> UserModel {
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accesToken)
        return try await signInWithCredential(credential: credential)
    }
}


//sign in with email

extension AuthManager {
    func createUser(email: String, password: String, name: String, username: String, photoUrl: String?) async throws -> UserModel {
        let authUser = try await Auth.auth().createUser(withEmail: email, password: password).user
        return UserModel(user: authUser, name: name, userName: username, photoUrl: photoUrl)
    }
    
    @discardableResult
    func signInUser(email: String, password: String) async throws -> UserModel {
        let authUser = try await Auth.auth().signIn(withEmail: email, password: password).user
        return UserModel(user: authUser)
    }
    
    
    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    
    func updatePassword(password: String) async throws {
        
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        
        try await user.updatePassword(to: password)
        
    }
    
    func updateEmail(email: String) async throws {
        
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        
        try await user.updateEmail(to: email)
    }
}
