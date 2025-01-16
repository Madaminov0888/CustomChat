//
//  MessageTempView.swift
//  CustomChat
//
//  Created by Muhammadjon Madaminov on 09/01/25.
//

import SwiftUI
import UIKit
import AVKit


struct MessageTempView: View {
    @EnvironmentObject private var parentVM: ChatRoomViewModel
    @StateObject private var vm = MessageTempViewModel()
    let mediaModel: MessageMediaTempModel
    let chat: ChatModel
    @State private var task: Task<Void, Never>? = nil
    
    
    var body: some View {
        VStack(alignment: .trailing) {
            switch mediaModel.content {
            case .image(let uIImage):
                Image(uiImage: uIImage)
                    .resizable()
                    .frame(maxWidth: 200, maxHeight: 200)
                    .scaledToFit()
                    .overlay {
                        Color.white.opacity(0.1)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .glassBlurView()
                            .overlay {
                                CSProgressView(.image)
                            }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            case .video(let url):
                VideoPlayer(player: AVPlayer(url: url))
                    .frame(maxWidth: 200, maxHeight: 200)
                    .scaledToFit()
                    .overlay {
                        Color.white.opacity(0.1)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .glassBlurView()
                            .overlay {
                                CSProgressView(.video)
                            }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            case .audio(let url):
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gray)
                    .frame(maxWidth: 300, maxHeight: 100)
                    .glassBlurView(Color.black)
                    .scaledToFit()
                    .overlay(alignment: .leading) {
                        Color.white.opacity(0.1)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .glassBlurView()
                            .overlay {
                                CSProgressView(.audio)
                            }
                            .padding(.leading)
                    }
            }
        }
        .onAppear(perform: {
            task = Task {
                switch mediaModel.content {
                case .image(let uIImage):
                    await vm.uploadImage(image: uIImage, chat: chat, id: mediaModel.id)
                case .video(let url):
                    await vm.uploadVideo(videoURL: url, chat: chat, id: mediaModel.id)
                case .audio(let url):
                    await vm.uploadAudio(audioURL: url, chat: chat, id: mediaModel.id)
                }
            }
        })
        .onDisappear(perform: {
            task?.cancel()
        })
        
        
        .onChange(of: vm.photoURL, { oldValue, newValue in
            Task {
                if let image = vm.photoURL {
                    await parentVM.sendMessageImage(chat: chat, messageID: mediaModel.id, imageURL: image)
                    await MainActor.run {
                        let index = parentVM.sendingImages.firstIndex(where: { $0.id == mediaModel.id })
                        parentVM.sendingImages.remove(atOffsets: IndexSet(integer: index ?? 0))
                    }
                }
            }
        })
        .onChange(of: vm.videoURL, { oldValue, newValue in
            Task {
                if let videoURL = vm.videoURL {
                    await parentVM.sendMessageVideo(chat: chat, messageID: mediaModel.id, videoURL: videoURL)
                    await MainActor.run {
                        let index = parentVM.sendingVideos.firstIndex(where: { $0.id == mediaModel.id })
                        parentVM.sendingVideos.remove(atOffsets: IndexSet(integer: index ?? 0))
                    }
                }
            }
        })
        .onChange(of: vm.audioURL, { oldValue, newValue in
            Task {
                if let audio = vm.audioURL {
                    await parentVM.sendMessageAudio(chat: chat, messageID: mediaModel.id, audioURL: audio)
                    await MainActor.run {
                        let index = parentVM.sendingAudios.firstIndex(where: { $0.id == mediaModel.id })
                        parentVM.sendingAudios.remove(atOffsets: IndexSet(integer: index ?? 0))
                    }
                }
            }
        })
        .padding(15)
    }
}




extension MessageTempView {
    @ViewBuilder private func CSProgressView(_ type: MediaType) -> some View {
        ZStack {
            // Black background
            Color.black.opacity(0.1)
                .glassBlurView(Color.white)
                .ignoresSafeArea()
            
            // Circular progress view
            ZStack {
                // Background circle
                Circle()
                    .stroke(lineWidth: 5)
                    .opacity(0.2)
                    .foregroundColor(.white)
                
                // Progress circle
                Circle()
                    .trim(from: 0.0, to: CGFloat(vm.progress))
                    .stroke(
                        Color.white,
                        style: StrokeStyle(lineWidth: 5, lineCap: .round)
                    )
                    .rotationEffect(Angle(degrees: -90))
                    .animation(.easeInOut, value: vm.progress)
                

                Image(systemName: type == .image ? "arrow.up" : type == .audio ? "arrow.up.right.video.fill" : "waveform.badge.microphone")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
    }
}




@MainActor
final class MessageTempViewModel: ObservableObject {
    @Published var progress: Double = 0
    @Published var photoURL: String? = nil
    
    @Published var videoURL: String? = nil
    @Published var audioURL: String? = nil
    
    private let storageManager = StorageManager()
    
    func uploadImage(image: UIImage, chat: ChatModel, id: String) async {
        do {
            let url = try await storageManager.uploadMessagePhoto(image: image, chatId: chat.id, messageId: id) { [weak self] progress in
                DispatchQueue.main.async {
                    self?.progress = progress?.fractionCompleted ?? 0
                }
            }
            await MainActor.run {
                self.photoURL = url.absoluteString
            }
            
        } catch {
            print("Error while uploading message image",error)
        }
    }
    
    
    func uploadVideo(videoURL: URL, chat: ChatModel, id: String) async {
        do {
            let url = try await storageManager.uploadMessageVideo(videoURL: videoURL, chatId: chat.id, messageId: id) { [weak self] progress in
                DispatchQueue.main.async {
                    self?.progress = progress?.fractionCompleted ?? 0
                }
            }
            await MainActor.run {
                self.videoURL = url.absoluteString
            }
        } catch {
            print("error uploading video",error)
        }
    }
    
    func uploadAudio(audioURL: URL, chat: ChatModel, id: String) async {
        do {
            let url = try await storageManager.uploadMessageAudio(audioURL: audioURL, chatId: chat.id, messageId: id) { [weak self] progress in
                DispatchQueue.main.async {
                    self?.progress = progress?.fractionCompleted ?? 0
                }
            }
            await MainActor.run {
                self.audioURL = url.absoluteString
            }
        } catch {
            print("error uploadAudio.MessageTempViewModel:",error)
        }
    }
}

