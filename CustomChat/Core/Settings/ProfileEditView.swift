//
//  ProfileEditView.swift
//  CustomChat
//
//  Created by Muhammadjon Madaminov on 11/01/25.
//

import SwiftUI
import UIKit


struct ProfileEditView: View {
    @EnvironmentObject private var vm: SettingsViewModel
    @State private var imagePickerSheet: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    ProfileImagePreview()
                        .overlay(alignment: .bottomLeading) {
                            Image(systemName: "camera.fill")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                                .fontWeight(.semibold)
                                .padding(10)
                                .glassBlurView(Color.white)
                                .clipShape(Circle())
                        }
                        .onTapGesture {
                            imagePickerSheet = true
                        }
                    
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
                        saveButtonPressed()
                    }
                    .disabled(!vm.changed)
                }
            })
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .tint(Color.primary)
            .sheet(isPresented: $imagePickerSheet, content: {
                ImagePickerView(sourceType: .photoLibrary) { vm.image = $0 }
                    .background(Color.white.ignoresSafeArea())
            })
            .onChange(of: vm.image) { oldValue, newValue in
                if newValue != nil { vm.changed = true }
            }
            
            if vm.uploading {
                UploadingCircleScreen()
                    .ignoresSafeArea()
                    .transition(.opacity)
            }
            
        }
    }
}

#Preview {
    ProfileEditView()
        .environmentObject(SettingsViewModel())
}




extension ProfileEditView {
    func saveButtonPressed() {
        if vm.changed {
            withAnimation {
                if vm.image != nil {
                    vm.uploading = true
                    Task {
                        await vm.uploadImage()
                    }
                } else {
                    vm.uploading = true
                    vm.progress = 1.0
                }
            }
        }
    }
}



extension ProfileEditView {
    @ViewBuilder private func ProfileImagePreview() -> some View {
        ZStack {
            if let image = vm.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
            } else if let imageURL = vm.user?.photoUrl {
                CustomImage(url: URL(string: imageURL)) {
                    ProgressView()
                        .frame(width: 150, height: 150)
                } imageView: { image in
                    image
                        .resizable()
                        .scaledToFill()
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





extension ProfileEditView {
    @ViewBuilder private func UploadingCircleScreen() -> some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .opacity(vm.uploading ? 1 : 0)
            
            ZStack {
                
                VStack {
                    circularProgressView()
                        .padding()
                    
                    Text(vm.progress == 1 ? "Done" : "Your data is being uploaded")
                        .foregroundStyle(Color.gray)
                        .font(.headline)
                        .padding(5)
                    
                    
                    Button {
                        vm.uploading = false
                        vm.progress = 0
                        Task {
                            await vm.sendUserChanges()
                            await MainActor.run {
                                dismiss.callAsFunction()
                            }
                        }
                        
                    } label: {
                        Text("Finish")
                            .foregroundStyle(Color.white)
                            .padding()
                            .frame(height: 55)
                            .padding(.horizontal)
                            .background(Color.csWelcome)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(radius: 5, y: 2)
                    }

                }
                .overlay(alignment: .topTrailing, content: {
                    Image(systemName: "xmark")
                        .font(.headline)
                        .foregroundStyle(Color.gray)
                        .padding()
                        .onTapGesture {
                            vm.uploading = false
                            vm.progress = 0
                        }
                })
                    .padding(20)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                
            }
            .ignoresSafeArea()
            .opacity(vm.uploading ? 1 : 0)
        }
    }
    
    
    
    @ViewBuilder
    private func circularProgressView() -> some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(lineWidth: 10)
                .opacity(0.3)
                .foregroundColor(.gray)
            
            // Progress circle
            Circle()
                .trim(from: 0.0, to: vm.progress)
                .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                .foregroundColor(vm.progress == 1.0 ? .green : .accentColor)
                .rotationEffect(Angle(degrees: -90))
                .animation(.linear(duration: 0.5), value: vm.progress)
            
            // Checkmark when completed
            if vm.progress == 1.0 {
                Image(systemName: "checkmark")
                    .font(.largeTitle)
                    .foregroundColor(.csWelcome)
                    .fontWeight(.bold)
                    .animation(.easeInOut, value: vm.progress)
            } else {
                Text("\(Int(vm.progress * 100))%")
                    .font(.headline)
                    .bold()
                    .foregroundColor(.csWelcome)
            }
        }
        .frame(width: 250, height: 250)
    }
}
