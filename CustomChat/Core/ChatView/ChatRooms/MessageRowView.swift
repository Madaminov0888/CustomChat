//
//  MessageRowView.swift
//  CustomChat
//
//  Created by Muhammadjon Madaminov on 16/03/24.
//

import SwiftUI
import AVKit

struct MessageRowView: View {
    
    @EnvironmentObject private var vm: ChatRoomViewModel
    let message: MessageModel
    let previewImageNamespace: Namespace.ID
    let currentUserID = try? AuthManager.shared.getAuthedUser().id
    
    var body: some View {
        HStack {
            
            if message.sender.authId == currentUserID {
                Spacer()
            }
                
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
                            .matchedGeometryEffect(id: message.id, in: previewImageNamespace)
                            .onTapGesture {
                                withAnimation(.bouncy(duration: 0.4)) {
                                    vm.previewImages = (image, message.id)
                                }
                            }
                    }
                    .frame(minWidth: 100, maxWidth: 300) // Minimum and maximum width for the image
                }
                
                if let videoURL = message.videoURL, let url = URL(string: videoURL) {
                    VStack {
                        VideoPlayer(player: .init(url: url))
                            .frame(maxWidth: .infinity)
                            .scaledToFit()
                    }
                    .frame(minWidth: 100, maxWidth: 300)
                }
                if let audioURL = message.audioURL, let url = URL(string: audioURL) {
                    VStack {
                        AudioPlayerView(audioURL: url)
                            .glassBlurView(currentUserID != message.sender.id ? Color.gray : Color.green)
                            .frame(width: 300)
                            .scaledToFit()
                    }
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
            .background(message.sender.authId != currentUserID ? Color.white : Color.green)
            .cornerRadius(20, corners: [.topLeft, .topRight, message.sender.authId != currentUserID ? .bottomRight : .bottomLeft])
            .foregroundStyle(message.sender.authId != currentUserID ? Color.black : Color.white)
            
            if message.sender.authId != currentUserID {
                Spacer()
            }
        }
        .padding(.horizontal, 5)
    }
}

//#Preview {
//    ZStack {
//        Color.cyan
//        
//        MessageRowView(message: Preview.message)
//    }
//}
