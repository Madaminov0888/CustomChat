//
//  AuthViewModel.swift
//  CustomChat
//
//  Created by Muhammadjon Madaminov on 29/02/24.
//

import Foundation
import UIKit


@MainActor
final class AuthViewModel: ObservableObject {
    
    @Published var authPickerValue: AuthPickerValue = .signUp
    @Published var code: String? = nil
    @Published var profileImage: UIImage? = nil
    @Published var username: String = ""
    @Published var nameField: String = ""
    
    @Published var email: String = ""
    @Published var passwd: String = ""
    @Published var photoURL: String? = nil
    @Published var uploading: Bool = false
    
    @Published var profileSetUp: Bool = false
    
    @Published var progress: Double = 0
    
    private let networkManager = NetworkManager()
    private let storageManager = StorageManager()
    
    
    //sign in with google
    func signInWithGoogleFunc() async {
        do {
            let tokens = try await GoogleSignInHelper().singIn()
            let user = try await AuthManager.shared.signInWithGoogle(tokens: tokens)
            try await networkManager.postUser(user: user)
        } catch {
            print(error)
        }
    }
    
    
    func getUser(uid: String) {
        Task {
            do {
                let _ = try await networkManager.getUserByID(uid: AuthManager.shared.getAuthedUser().id)
            } catch {
                print("[] \(error)")
            }
        }
    }
    
    
    //sign up with email
    func signUpWithEmail() {
        Task {
            do {
                let authedUser = try await AuthManager.shared.createUser(
                    email: email,
                    password: passwd,
                    name: nameField,
                    username: username,
                    photoUrl: photoURL)
                print(photoURL ?? "no url")
                try await networkManager.postUser(user: authedUser)
            } catch {
                print(error)
            }
        }
    }
    
    func signInWithEmail(email: String, password: String) {
        Task {
            do {
                let authedUser = try await AuthManager.shared.signInUser(email: email, password: password)
                try await networkManager.postUser(user: authedUser)
            } catch {
                print(error)
            }
        }
    }
    
    
    func updloadPhoto() {
        Task {
            do {
                if let image = profileImage {
                    let downloadURL = try await storageManager.uploadUserPhoto(image: image) { [weak self] progress in
                        DispatchQueue.main.async {
                            self?.progress = progress?.fractionCompleted ?? 0
                        }
                    }
                    await MainActor.run {
                        self.photoURL = downloadURL.absoluteString
                        print("set: \(downloadURL)")
                    }
                } else {
                    throw URLError(.badURL)
                }
            } catch {
                print("error while uploading profile photo:", error.localizedDescription)
            }
        }
    }
}
