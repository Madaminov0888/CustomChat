//
//  ChatRoomView.swift
//  CustomChat
//
//  Created by Muhammadjon Madaminov on 14/03/24.
//
import SwiftUI
import PhotosUI


struct ChatRoomView: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject private var vm = ChatRoomViewModel()
    let chat: ChatModel
    
    @State private var showImagePicker: Bool = false
    
    var body: some View {
        ZStack {
            
            Color.csBackground
                .ignoresSafeArea(edges: .bottom)
            
            VStack {
                
                //Header
                HeaderView()
                
                
                //Messages
                ScrollView {
                    ScrollViewReader(content: { proxy in
                        LazyVStack {
                            ForEach(vm.getMessagesWithIntervals(), id: \.0.id) { message, showText in
                                if showText {
                                    Text(Date.formatDateStringHeader(message.dateSent))
                                }
                                MessageRowView(message: message).id(message.id)
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
                        .onChange(of: vm.messages.count, { oldValue, newValue in
                            proxy.scrollTo(vm.messages.last?.id)
                        })
                    })
                }
                .overlay(alignment: .bottomLeading) {
                    if vm.selectedUIImages.count > 0 {
                        ImagesPreview()
                    }
                }
                
                MessageField()
                    .padding(.horizontal)
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
    
    
    @ViewBuilder private func MessageField() -> some View {
        HStack {
            TextField("Message...", text: $vm.messageText)
                .autocorrectionDisabled(true)
                .textfieldModifier()
                .overlay(alignment: .leading) {
                    PhotosPicker(selection: $vm.selectedImages, maxSelectionCount: 3, selectionBehavior: .continuous, matching: .images, preferredItemEncoding: .automatic) {
                        Image(systemName: "paperclip")
                            .font(.headline)
                            .foregroundStyle(Color.gray)
                    }
                    .buttonStyle(.plain)
                    .padding(.leading)
                }
            
            Button(action: {
                if vm.selectedUIImages.count < 1 {
                    Task {
                        await vm.sendMessage(chat: chat)
                        vm.messageText = ""
                    }
                } else {
                    vm.sendingImages = vm.selectedUIImages.map({ MessageImageTempModel(id: UUID().uuidString, image: $0) })
                    vm.selectedImages.removeAll()
                    vm.selectedUIImages.removeAll()
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
        .onChange(of: vm.selectedImages) { oldValue, newValue in
            if newValue.count > 0 {
                Task {
                    await vm.getUIImages()
                }
            } else if newValue.count == 0 {
                vm.selectedImages.removeAll()
                vm.selectedUIImages.removeAll()
            }
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
                MessageTempView(imageModel: imageModel, chat: chat)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    
    @ViewBuilder private func ImagesPreview() -> some View {
        ZStack {
            if showImagePicker {
                HStack(spacing: 0) {
                    ForEach(vm.selectedUIImages, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .frame(width: 90, height: 90)
                            .scaledToFill()
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .padding(10)
                            .animation(.smooth, value: showImagePicker)
                    }
                }
            } else {
                Image(systemName: "photo")
                    .font(.title)
                    .foregroundStyle(Color.gray.opacity(0.7))
                    .fontWeight(.bold)
                    .padding(10)
            }
        }
        .onTapGesture {
            withAnimation(.bouncy) {
                self.showImagePicker.toggle()
            }
        }
        .glassBlurView(Color.white)
        .overlay(alignment: .topTrailing, content: {
            Text("\(vm.selectedUIImages.count)")
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
