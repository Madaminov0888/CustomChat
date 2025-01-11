//
//  ChatsRowView.swift
//  CustomChat
//
//  Created by Muhammadjon Madaminov on 13/03/24.
//

import SwiftUI

struct ChatsRowView: View {
    
    @EnvironmentObject var vm: ChatViewModel
    let chat: ChatModel
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                
                ProfileImageView(otherUser: vm.getOtherUser(chat: chat))
                    .frame(width: 50, height: 50)
                    .padding(.leading)
                
                
                VStack {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(vm.getOtherUser(chat: chat)?.name ?? (vm.getOtherUser(chat: chat)?.email ?? "Unknown"))
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            Text(vm.getLastMessage(chat: chat)?.content ?? "")
                                .font(.subheadline)
                                .foregroundStyle(Color.gray)
                                .fontWeight(.semibold)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing,spacing: 0) {
                            let num = vm.countUnseenMessages(messages: chat.chat_messages)
                            
                            Text(Date.formatDateString(chat.chat_messages.last?.dateSent ?? ""))
                                .font(.footnote)
                                .bold()
                                .opacity(0.4)
                                .padding(.trailing)
                                .padding(.top)
                            
                            if num != "0" {
                                Text(num)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color.white)
                                    .padding(10)
                                    .background(
                                        Circle()
                                            .foregroundStyle(Color.blue)
                                    )
                                    .padding(.trailing)
                            } else {
                                Text("")
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color.white)
                                    .padding(10)
                                    .background(
                                        Circle()
                                            .foregroundStyle(Color.clear)
                                    )
                                    .padding(.trailing)
                            }
                        }
                    }
                    
                    Divider()
                }
            }
            .fontDesign(.rounded)
            .frame(maxWidth: .infinity)
            .frame(height: 75)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .contentShape(Rectangle())
        }
    }
}



#Preview {
    ChatsRowView(chat: Preview.devChatModel)
        .environmentObject(ChatViewModel())
}
