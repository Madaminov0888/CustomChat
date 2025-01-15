//
//  ChatView.swift
//  CustomChat
//
//  Created by Muhammadjon Madaminov on 01/03/24.
//

import SwiftUI

struct ChatView: View {
    
    @EnvironmentObject var vm: ChatViewModel
    @State private var selectedChat: ChatModel? = nil
    @AppStorage("isAuthed") private var isAuthed = true

    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea(edges: .bottom)
            
            Color.mainColor
                .ignoresSafeArea(edges: .top)
            
            
            VStack {
                
                ScrollView {
                    LazyVStack(spacing: 0) {
                        if vm.chats.isEmpty {
                            Image("noChats")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity)
                                .frame(height: 300)
                                .padding(20)
                            
                            Text("Hmm... no chats here yet!")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.primary)
                                .padding(.top, 20)
                            
                            Text("Chat a friend to get started")
                                .font(.headline)
                                .fontWeight(.light)
                                .foregroundStyle(Color.secondary)
                        }
                        ForEach(vm.chats) { chat in
                            ChatsRowView(chat: chat)
                                .environmentObject(vm)
                                .onTapGesture {
                                    selectedChat = chat
                                }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .background(Color.white)
            }
            .navigationTitle("Chats")
            .navigationBarTitleDisplayMode(.automatic)
            .searchable(text: $vm.chatSearchText)
        }
        .sheet(isPresented: $vm.showUsersSheet, content: {
            UsersSheetView()
        })
        .navigationDestination(isPresented: Binding(value: $selectedChat), destination: {
            if let chat = self.selectedChat {
                ChatRoomView(chat: chat)
            }
        })
        .task {
            try? await vm.loadUserChats()
            await vm.connectionHandler()
        }
        .onChange(of: vm.showUsersSheet, { oldValue, newValue in
            if newValue {
                vm.getSearchUsers()
            } else {
                Task {
                    try? await vm.loadUserChats()
                    await vm.connectionHandler()
                }
            }
        })
        .fontDesign(.rounded)
        .refreshable {
            Task {
                try? await vm.loadUserChats()
                await vm.connectionHandler()
            }
        }
    }
}




extension ChatView {
    @ViewBuilder private func UsersSheetView() -> some View {
        NavigationStack {
            List {
                ForEach(vm.searchUsers) { user in
                    UsersRowView(user: user)
                        .onTapGesture {
                            Task {
                                let chat = await vm.postChat(user: user)
                                await MainActor.run {
                                    vm.showUsersSheet = false
                                    selectedChat = chat
                                }
                            }
                        }
                }
            }
            .navigationTitle(Text("Users"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        self.vm.showUsersSheet = false
                    } label: {
                        Text("Cancel")
                    }
                }
            }
            .searchable(text: $vm.searchText, prompt: "Search")
            .onChange(of: vm.searchText) { oldValue, newValue in
                vm.searchUsers = vm.allUsersList.filter({ ($0.name?.lowercased().contains(newValue.lowercased()) ?? false) || ($0.email?.lowercased().contains(newValue.lowercased()) ?? false) })
                if newValue.isEmpty {
                    vm.searchUsers = vm.allUsersList
                }
            }
        }
    }
    
    
    @ViewBuilder private func UsersRowView(user: UserModel) -> some View {
        HStack {
            ProfileImageView(otherUser: user)
                .frame(width: 50, height: 50)
            
            VStack(alignment: .leading) {
                Text(user.name ?? "")
                    .font(.headline)
                    .foregroundColor(Color.primary)
                    .lineLimit(1)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .shadow(radius: 10)
                
                Text(user.email ?? "")
                    .font(.subheadline)
                    .foregroundColor(Color.secondary)
                    .lineLimit(1)
                    .shadow(radius: 10)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.white.opacity(0.5))
            
            Spacer()
        }
    }
}





#Preview {
    NavigationStack {
        ChatView()
            .environmentObject(ChatViewModel())
    }
}


//
//
//
//extension ChatView {
//    
//    @ViewBuilder private func HeaderView() -> some View {
//        
//        HStack {
////            Button(action: {
////                do {
////                    try AuthManager.shared.logOut()
////                    isAuthed = false
////                } catch {
////                    print(error)
////                }
////            }, label: {
////                Image(systemName: "gearshape.fill")
////                    .font(.title2)
////                    .padding(10)
////                    .background(Color.clear)
////                    .glassBlurView(.white, 15)
////            })
////            .tint(.white)
//            
//            Text("Chats")
//                .foregroundStyle(Color.white)
//                .font(.title)
//                .fontWeight(.bold)
//                .frame(maxWidth: .infinity)
//        
//            
////            Button(action: {
////                self.vm.showUsersSheet = true
////            }, label: {
////                Image(systemName: "square.and.pencil")
////                    .font(.title2)
////                    .padding(10)
////                    .padding(.bottom, 1)
////                    .background(Color.clear.clipShape(RoundedRectangle(cornerRadius: 0.5)))
////                    .glassBlurView(.white, 15)
////            })
////            .tint(.white)
////
//        }
//        
//    }
//    
//}
