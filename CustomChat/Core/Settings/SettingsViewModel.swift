//
//  SettingsViewModel.swift
//  CustomChat
//
//  Created by Muhammadjon Madaminov on 10/01/25.
//

import Foundation


final class SettingsViewModel: ObservableObject {
    @Published var user: UserModel? = nil {
        didSet {
            getUser()
        }
    }
    
    @Published var name: String = "" {
        didSet {
            checkForChanges()
        }
    }
    @Published var surname: String = "" {
        didSet {
            checkForChanges()
        }
    }
    @Published var username: String = "" {
        didSet {
            checkForChanges()
        }
    }
    @Published var phoneNumber: String = "+998" {
        didSet {
            checkForChanges()
        }
    }
    @Published var changed: Bool = false
    
    
    private let networkManager = NetworkManager()
    
    func getImageURL(id: String?) async {
        guard let id else { return }
        do {
            let user = try await networkManager.getUserByID(uid: id)
            await MainActor.run {
                self.user = user
            }
        } catch {
            print("SettingsViewModel,getImageURL",error)
        }
    }
    
    func getUser() {
        guard let user else { return }
        let splitName = splitName(user.name ?? "")
        name = splitName.name
        surname = splitName.surname ?? ""
        self.phoneNumber = user.phoneNumber ?? ""
        self.username = user.userName ?? ""
    }
    
    func splitName(_ fullName: String) -> (name: String, surname: String?) {
        let components = fullName.split(separator: " ", maxSplits: 1).map(String.init)
        if components.count == 2 {
            return (name: components[0], surname: components[1])
        } else {
            return (name: fullName, surname: nil)
        }
    }
    
    private func checkForChanges() {
        guard let user else {
            changed = false
            return
        }
        
        // Compare current values with the original user values
        let originalSplitName = splitName(user.name ?? "")
        let isNameChanged = name != originalSplitName.name
        let isSurnameChanged = surname != (originalSplitName.surname ?? "")
        let isUsernameChanged = username != (user.userName ?? "")
        let isPhoneNumberChanged = phoneNumber != (user.phoneNumber ?? "")
        
        // Set `changed` to true if any value differs
        changed = isNameChanged || isSurnameChanged || isUsernameChanged || isPhoneNumberChanged
    }
}
