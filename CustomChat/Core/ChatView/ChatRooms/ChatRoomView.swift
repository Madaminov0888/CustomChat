//
//  ChatRoomView.swift
//  CustomChat
//
//  Created by Muhammadjon Madaminov on 14/03/24.
//
import SwiftUI
import PhotosUI
import AVKit


struct ChatRoomView: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject private var vm = ChatRoomViewModel()
    @Namespace var previewImageNamespace
    @State private var pickerItems: [PhotosPickerItem] = []

    let chat: ChatModel
    
    @State private var showImagePicker: Bool = false
    
    var body: some View {
        ZStack {
            
            Color.csBackground
                .ignoresSafeArea(edges: .bottom)
                .onTapGesture {
                    withAnimation(.bouncy) {
                        self.showImagePicker.toggle()
                    }
                }
            
            VStack {
                
                //Header
                HeaderView()
                
                
                //Messages
                ScrollView {
                    ScrollViewReader(content: { proxy in
                        MessagesStack()
                            .onChange(of: vm.messages.count, { oldValue, newValue in
                                proxy.scrollTo(vm.messages.last?.id)
                            })
                            .onAppear {
                                proxy.scrollTo(vm.messages.last?.id)
                            }
                    })
                }
                .overlay(alignment: .bottomLeading) {
                    VStack(alignment: .leading) {
                        if vm.getImagesCount() > 0 {
                            ImagesPreview(type: .image)
                        }
                        if vm.getVideosCount() > 0 {
                            ImagesPreview(type: .video)
                        }
                    }
                }
                
                MessageField()
                    .padding(.horizontal)
            }
            
            Color.black
                .ignoresSafeArea()
                .opacity(vm.previewImages != nil ? 1 : 0)
                .animation(.easeOut(duration: 0.4), value: vm.previewImages?.image)
            
            if let image = vm.previewImages?.image, let id = vm.previewImages?.id {
                image
                    .resizable()
                    .scaledToFit()
                    .padding(.top)
                    .matchedGeometryEffect(id: id, in: previewImageNamespace)
                    .zIndex(0)
            }
            
            if let _ = vm.previewImages?.image {
                ImagePreviewXmark()
            }
            
        }
        .environmentObject(vm)
        .navigationBarBackButtonHidden()
        .task {
            await vm.loadMessages(chat: chat)
            await vm.recieveMessage(chat: chat)
        }
    }
}






extension ChatRoomView {
    private func onAppearMessageStateFunc(message: MessageModel) {
        if !message.isItSeen && message.sender.authId != (try? AuthManager.shared.getAuthedUser().id) {
            Task(priority: .low) {
                await vm.sendMessageState(message: message, chat: chat)
            }
        }
    }
    
    
    
    @ViewBuilder private func MessagesStack() -> some View {
        LazyVStack {
            ForEach(vm.getMessagesWithIntervals(), id: \.0.id) { message, showText in
                if showText {
                    Text(Date.formatDateStringHeader(message.dateSent))
                }
                MessageRowView(message: message, previewImageNamespace: previewImageNamespace).id(message.id)
                    .onAppear(perform: {
                        onAppearMessageStateFunc(message: message)
                    })
                    .overlay(alignment: .bottomTrailing) {
                        if message.sender.id == (try? AuthManager.shared.getAuthedUser().id) {
                            if message.isItSeen {
                                Text("Seen")
                                    .font(.footnote)
                                    .fontWeight(.semibold)
                                    .fontDesign(.rounded)
                                    .padding(.trailing, 10)
                                    .padding(.bottom, 5)
                                    .opacity(0.7)
                                    .foregroundStyle(Color.white)
                            }
                        }
                    }
            }
            
            Rectangle()
                .foregroundStyle(Color.clear)
                .frame(width: 100, height: 100)
            
            if vm.sendingImages.count > 0 {
                TempImageMessages()
            }
        }
    }
    
    
    
    @ViewBuilder private func ImagePreviewXmark() -> some View {
        VStack(alignment: .trailing) {
            HStack(alignment: .top) {
                Spacer()
                Button {
                    vm.previewImages = nil
                } label: {
                    Image(systemName: "xmark")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.white)
                        .contentShape(Circle())
                }
                .buttonStyle(.plain)
                .padding()
                .padding(.top)
            }
            Spacer()
        }
    }
    
    
    
    @ViewBuilder private func MessageField() -> some View {
        HStack {
            TextField("Message...", text: $vm.messageText)
                .autocorrectionDisabled(true)
                .textfieldModifier()
                .overlay(alignment: .leading) {
                    PhotosPicker(selection: $pickerItems, maxSelectionCount: 3, selectionBehavior: .continuous, matching: .any(of: [.images, .videos]), preferredItemEncoding: .automatic) {
                        Image(systemName: "paperclip")
                            .font(.headline)
                            .foregroundStyle(Color.gray)
                    }
                    .buttonStyle(.plain)
                    .padding(.leading)
                    .onChange(of: pickerItems) { oldValue, newValue in
                        Task {
                            await vm.handlePickerItems(newValue)
                        }
                    }
                }
            
            Button(action: {
                if vm.getImagesCount() < 1 && vm.getVideosCount() < 1 {
                    Task {
                        await vm.sendMessage(chat: chat)
                        await MainActor.run{ vm.messageText = "" }
                    }
                } else {
                    vm.getImageVideo()
                    vm.selectedMedia.removeAll()
                    pickerItems.removeAll()
                    vm.messageText = ""
                }
            }, label: {
                Image(systemName: "arrow.up")
                    .font(.title)
                    .foregroundStyle(Color.white)
                    .padding()
                    .background(Color.accentColor)
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            })
        }
    }
    
    
    @ViewBuilder private func HeaderView() -> some View {
        HStack {
            
            Button(action: {
                dismiss.callAsFunction()
            }, label: {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundStyle(Color.black)
                    .bold()
            })
            .padding()
            
            Spacer()
            
            Text(vm.getOtherUser(chat: chat)?.name ?? "")
                .padding()
                .font(.title2)
                .fontWeight(.semibold)
            Spacer()
            
            ProfileImageView(otherUser: vm.getOtherUser(chat: chat))
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .padding(.horizontal)
            
        }
        .frame(maxWidth: .infinity)
        .background(Color.white.cornerRadius(20, corners: [.bottomLeft, .bottomRight]))
    }
}


#Preview {
    ChatRoomView(chat: Preview.devChatModel)
}





//MARK: View Components
extension ChatRoomView {
    @ViewBuilder private func TempImageMessages() -> some View {
        VStack(alignment: .trailing, spacing: 0) {
            ForEach(vm.sendingImages) { imageModel in
                MessageTempView(mediaModel: imageModel, chat: chat)
            }
            ForEach(vm.sendingVideos) { videoModel in
                MessageTempView(mediaModel: videoModel, chat: chat)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    
    @ViewBuilder private func ImagesPreview(type: MediaType) -> some View {
        ZStack {
            if showImagePicker {
                HStack(spacing: 0) {
                    ForEach(vm.selectedMedia.filter({ $0.type == type })) { model in
                        VStack {
                            switch model.content {
                            case .image(let image):
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 90, height: 90)
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                                    .padding(10)
                                    .animation(.smooth, value: showImagePicker)
                            case .video(let video):
                                VideoPlayer(player: AVPlayer(url: video))
                                    .frame(width: 120, height: 120)
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                                    .padding(10)
                            }
                        }
                    }
                }
            } else {
                Image(systemName: type == .image ? "photo" : "video.fill")
                    .font(.title)
                    .foregroundStyle(Color.gray.opacity(0.7))
                    .fontWeight(.bold)
                    .padding(10)
            }
        }
        .glassBlurView(Color.white)
        .onTapGesture {
            withAnimation(.bouncy) {
                self.showImagePicker.toggle()
            }
        }
        .overlay(alignment: .topTrailing, content: {
            Text(type == .image ? vm.getImagesCount().description : vm.getVideosCount().description)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(Color.white)
                .padding(5)
                .background(Color.accentColor)
                .clipShape(Circle())
                .offset(x: 5, y: -5)
        })
        .padding(.horizontal)
    }
}
