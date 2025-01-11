//
//  MessageTempView.swift
//  CustomChat
//
//  Created by Muhammadjon Madaminov on 09/01/25.
//

import SwiftUI
import UIKit


struct MessageTempView: View {
    @EnvironmentObject private var parentVM: ChatRoomViewModel
    @StateObject private var vm = MessageTempViewModel()
    let imageModel: MessageImageTempModel
    let chat: ChatModel
    @State private var task: Task<Void, Never>? = nil
    
    
    var body: some View {
        VStack(alignment: .trailing) {
            Image(uiImage: imageModel.image)
                .resizable()
                .frame(maxWidth: 200, maxHeight: 200)
                .scaledToFit()
                .overlay {
                    Color.white.opacity(0.1)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .glassBlurView()
                        .overlay {
                            CSProgressView()
                        }
                }
                .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .onAppear(perform: {
            task = Task {
                await vm.uploadImage(image: imageModel.image, chat: chat, id: imageModel.id)
            }
        })
        .onDisappear(perform: {
            task?.cancel()
        })
        
        
        .onChange(of: vm.photoURL, { oldValue, newValue in
            Task {
                if let image = vm.photoURL {
                    await parentVM.sendMessageImage(chat: chat, messageID: imageModel.id, imageURL: image)
                    await MainActor.run {
                        let index = parentVM.sendingImages.firstIndex(where: { $0.id == imageModel.id })
                        parentVM.sendingImages.remove(atOffsets: IndexSet(integer: index ?? 0))
                    }
                }
            }
        })
        .padding(15)
    }
}




extension MessageTempView {
    @ViewBuilder private func CSProgressView() -> some View {
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
                

                Image(systemName: "arrow.up")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundColor(.white)
            }
            .frame(width: 100, height: 100) // Adjust the size as needed
        }
    }
}




@MainActor
final class MessageTempViewModel: ObservableObject {
    @Published var progress: Double = 0
    @Published var photoURL: String? = nil
    
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
}

