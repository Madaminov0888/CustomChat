//
//  MessageRowView.swift
//  CustomChat
//
//  Created by Muhammadjon Madaminov on 16/03/24.
//

import SwiftUI

struct MessageRowView: View {
    
    let message: MessageModel
    let currentUserID = try? AuthManager.shared.getAuthedUser().id
    
    var body: some View {
        HStack {
            
            if message.sender.authId == currentUserID {
                Spacer()
            }
            
//            VStack(alignment: message.sender.authId == (try? AuthManager.shared.getAuthedUser().id) ? .leading : .trailing) {
//                if let url = message.photoURL{
//                    CustomImage(url: URL(string: url)) {
//                        ProgressView()
//                            .frame(maxWidth: 200, maxHeight: 200)
//                    } imageView: { image in
//                        image
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .frame(maxWidth: .infinity, maxHeight: 200)
//                    }
//
//                }
//                
//                if message.content.count > 0 {
//                    Text(message.content)
//                        .padding(.horizontal)
//                        .padding(.top, 10)
//                }
//                
//                VStack(alignment: .trailing,spacing: 0) {
//                    Text(Date.formatDateStringTimeOnly(message.dateSent))
//                        .font(.footnote)
//                }
//                .bold()
//                .opacity(0.5)
//                .padding(.bottom, 3)
//                .padding(.horizontal, 15)
//                .padding(.trailing, message.sender.authId == (try? AuthManager.shared.getAuthedUser().id) ? 30 : 15)
//            }
//            .foregroundStyle(message.sender.authId != (try? AuthManager.shared.getAuthedUser().id) ? Color.black : Color.white)
//            .background(message.sender.authId != (try? AuthManager.shared.getAuthedUser().id) ? Color.white : Color.green)
//            .cornerRadius(20, corners: [.topLeft, .topRight, message.sender.authId != (try? AuthManager.shared.getAuthedUser().id) ? .bottomRight : .bottomLeft])
//            
            VStack(alignment: message.sender.authId == currentUserID ? .leading : .trailing) {
                if let url = message.photoURL {
                    CustomImage(url: URL(string: url)) {
                        ProgressView()
                            .frame(maxWidth: 200, maxHeight: 200)
                            .padding()
                    } imageView: { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                            .clipped()
                    }
                    .frame(minWidth: 100, maxWidth: 300) // Minimum and maximum width for the image
                }

                if message.content.count > 0 {
                    if message.photoURL != nil {
                        Text(message.content)
                            .padding(.horizontal)
                            .frame(minWidth: 100, maxWidth: 300, alignment: .leading)
                    } else {
                        Text(message.content)
                            .padding(.horizontal)
                            .padding(.top, 10)
                    }
                }

                VStack(alignment: .trailing, spacing: 0) {
                    Text(Date.formatDateStringTimeOnly(message.dateSent))
                        .font(.footnote)
                }
                .bold()
                .opacity(0.5)
                .padding(.bottom, 3)
                .padding(.horizontal, 15)
                .padding(.trailing, message.sender.authId == currentUserID ? 30 : 15)
            }
//            .padding()
            .background(message.sender.authId != currentUserID ? Color.white : Color.green)
            .cornerRadius(20, corners: [.topLeft, .topRight, message.sender.authId != currentUserID ? .bottomRight : .bottomLeft])
            .foregroundStyle(message.sender.authId != currentUserID ? Color.black : Color.white)
//            .frame(maxWidth: UIScreen.main.bounds.width * 0.8, alignment: message.sender.authId != currentUserID ? .leading : .trailing)
            
            if message.sender.authId != currentUserID {
                Spacer()
            }
        }
        .padding(.horizontal, 5)
    }
}

#Preview {
    ZStack {
        Color.cyan
        
        MessageRowView(message: Preview.message)
    }
}
