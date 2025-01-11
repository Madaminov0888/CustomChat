//
//  GoogleSignInHelper.swift
//  FireBaseBootcamp
//
//  Created by Muhammadjon Madaminov on 06/02/24.
//

import Foundation
import GoogleSignIn
import GoogleSignInSwift


struct TokensModel {
    let idToken: String
    let accesToken: String
    let email: String?
    let name: String?
}


final class GoogleSignInHelper {
    
    @MainActor
    func singIn() async throws -> TokensModel {
        guard let topVC = Utilities.shared.topViewController() else { throw URLError(.badURL) }
        
        let GIDResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)
        
        let accesToken: String = GIDResult.user.accessToken.tokenString
        guard let idToken = GIDResult.user.idToken?.tokenString else {
            throw URLError(.dataNotAllowed)
        }
        let name = GIDResult.user.profile?.name
        let email = GIDResult.user.profile?.email
        
        let googleSignInResult = TokensModel(idToken: idToken, accesToken: accesToken, email: email, name: name)
        return googleSignInResult
    }
    
}
