//
//  ProfileEditView.swift
//  CustomChat
//
//  Created by Muhammadjon Madaminov on 11/01/25.
//

import SwiftUI

struct ProfileEditView: View {
    @EnvironmentObject private var vm: SettingsViewModel
    
    var body: some View {
        ScrollView {
            VStack {
                ProfileImagePreview()
                
                List {
                    Section {
                        TextFieldView(text: "Name", title: $vm.name)
                        
                        TextFieldView(text: "Surname", title: $vm.surname)
                    }
                    
                    Section {
                        TextFieldView(text: "Phone number", title: $vm.phoneNumber)
                        TextFieldView(text: "Username", title: $vm.username)
                    }
                }
                .frame(height: UIScreen.main.bounds.height * 0.7)
                .scrollDisabled(true)
            }
            .frame(maxWidth: .infinity)
            .background(Color(uiColor: .systemGroupedBackground))
        }
        .toolbar(content: {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    
                    
                    
                }
            }
        })
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
        .tint(Color.primary)
    }
}

#Preview {
    ProfileEditView()
        .environmentObject(SettingsViewModel())
}





extension ProfileEditView {
    @ViewBuilder private func ProfileImagePreview() -> some View {
        ZStack {
            if let imageURL = vm.user?.photoUrl {
                CustomImage(url: URL(string: imageURL)) {
                    ProgressView()
                        .frame(width: 150, height: 150)
                } imageView: { image in
                    image
                        .resizable()
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                }
            } else {
                if let name = vm.user?.name?.first {
                    Text(name.uppercased())
                        .font(.system(size: 30))
                        .fontWeight(.bold)
                        .foregroundStyle(Color.primary)
                        .frame(width: 150, height: 150)
                        .background(Color.green)
                        .clipShape(Circle())
                } else {
                    Text("U")
                        .font(.system(size: 30))
                        .fontWeight(.bold)
                        .foregroundStyle(Color.primary)
                        .frame(width: 150, height: 150)
                        .background(Color.green)
                        .clipShape(Circle())
                }
            }
        }
    }
    
    @ViewBuilder private func TextFieldView(text: String, title: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            if !title.wrappedValue.isEmpty {
                Text(text)
                    .font(.callout)
                    .foregroundStyle(Color.secondary)
                    .fontWeight(.semibold)
                    .transition(.asymmetric(insertion: .opacity, removal: .identity)) // Transition for entering/exiting
                    .animation(.bouncy, value: vm.name.isEmpty)
            }
            TextField(!title.wrappedValue.isEmpty ? "" : text, text: title)
                .padding(.bottom, 1)
        }
        .animation(.spring(duration: 0.5, bounce: 0, blendDuration: 0), value: title.wrappedValue)
    }
}
