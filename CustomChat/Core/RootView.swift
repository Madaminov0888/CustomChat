//
//  RootView.swift
//  CustomChat
//
//  Created by Muhammadjon Madaminov on 29/02/24.
//

import SwiftUI

struct RootView: View {
    @AppStorage("isAuthed") var isAuthed: Bool = false
    
    var body: some View {
        ZStack {
            if isAuthed {
                ZStack {
                    TabBarView()
                    
                }
            } else {
                AuthView()
            }
        }
        .onAppear(perform: {
            let user = try? AuthManager.shared.getAuthedUser()
            if user == nil {
                isAuthed = false
            }
        })
    }
}

#Preview {
    NavigationStack {
        RootView()
    }
}
