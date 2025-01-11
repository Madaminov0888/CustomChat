//
//  SettingsView.swift
//  CustomChat
//
//  Created by Muhammadjon Madaminov on 08/01/25.
//

import SwiftUI

struct SettingsView: View {
    let user = try? AuthManager.shared.getAuthedUser()
    @AppStorage("isAuthed") var isAuthed: Bool = true
    @StateObject private var vm = SettingsViewModel()
    
    var body: some View {
        VStack {
            List {
                Section {
                    NavigationLink {
                        ProfileEditView()
                            .environmentObject(vm)
                    } label: {
                        profileSection()
                    }

                }
                
                Section {
                    buttonsSection(symbol: "rectangle.portrait.and.arrow.right.fill", text: "Log out") {
                        try? AuthManager.shared.logOut()
                        isAuthed = false
                    }
                    buttonsSection(symbol: "trash.fill", symbolColor: .red, text: "Delete account") {
                        Task {
                            try? await AuthManager.shared.deleteUser()
                            await MainActor.run {
                                isAuthed = false
                            }
                        }
                    }
                }
            }
        }
        .task {
            await vm.getImageURL(id: user?.id)
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.automatic)
    }
}



extension SettingsView {
    @ViewBuilder private func profileSection() -> some View {
        HStack {
            if let imageURL = vm.user?.photoUrl {
                CustomImage(url: URL(string: imageURL)) {
                    ProgressView()
                        .frame(width: 90, height: 90)
                } imageView: { image in
                    image
                        .resizable()
                        .frame(width: 90, height: 90)
                        .clipShape(Circle())
                }
            } else {
                if let name = vm.user?.name?.first {
                    Text(name.uppercased())
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.primary)
                        .frame(width: 90, height: 90)
                        .background(Color.green)
                        .clipShape(Circle())
                } else {
                    Text("U")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.primary)
                        .frame(width: 90, height: 90)
                        .background(Color.green)
                        .clipShape(Circle())
                }
            }
            
            VStack(alignment: .leading) {
                Text("\(vm.user?.name ?? "")")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .shadow(radius: 5)
                
                Text("\(user?.email ?? "")")
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                    .shadow(radius: 5)
            }
            .padding(.horizontal, 5)
        }
        .padding(5)
    }
    
    
    @ViewBuilder private func buttonsSection(symbol: String, symbolColor: Color = .primary ,text: String, action: @escaping () -> ()) -> some View {
        Button {
            action()
        } label: {
            HStack {
                Image(systemName: symbol)
                    .renderingMode(.original)
                    .font(.title2)
                    .foregroundColor(symbolColor)
                    .padding(.horizontal,5)
                    
                Text(text)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .fontWeight(.regular)
                    .shadow(radius: 5)
                    .padding(.horizontal,5)
                
                Spacer()
            }
        }

    }
}




#Preview {
    SettingsView()
}
