//
//  RegisterView.swift
//  CustomChat
//
//  Created by Muhammadjon Madaminov on 06/01/25.
//

import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var vm: AuthViewModel
    @State private var imagePickerSheet: Bool = false
    @AppStorage("isAuthed") private var showRegisterView: Bool = false
    
    var body: some View {
        ZStack {
            
            VStack {
                Text("Set up your profile")
                    .font(.system(size: 30))
                    .fontWeight(.heavy)
                    .foregroundStyle(Color.csWelcomeColor)
                    .fontDesign(.rounded)
                    .padding(.top)
                
                
                ProfileImageBlock()
                .onTapGesture {
                    imagePickerSheet = true
                }
                
                TextFieldsBlock()
                
                
                Button {
                    if !vm.nameField.isEmpty && !vm.username.isEmpty {
                        withAnimation {
                        if vm.profileImage != nil {
                                vm.uploading = true
                                vm.updloadPhoto()
                            } else {
                                vm.uploading = true
                                vm.progress = 1.0
                            }
                        }
                    }
                } label: {
                    Text("Register")
                        .foregroundStyle(Color.white)
                        .padding()
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                        .background(Color.csWelcome)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(radius: 5, y: 2)
                }
                .buttonStyle(.plain)
                .padding()

                
            }
            .ignoresSafeArea()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.vertical, 30)
            .padding()
            .glassBlurView(.white)
            .padding()
            .disabled(vm.uploading)
        }
        .ignoresSafeArea()
        .sheet(isPresented: $imagePickerSheet, content: {
            ImagePickerView(sourceType: .photoLibrary) { vm.profileImage = $0 }
                .background(Color.white.ignoresSafeArea())
        })
    }
}

#Preview {
    RegisterView()
        .environmentObject(AuthViewModel())
}






extension RegisterView {
    @ViewBuilder private func ProfileImageBlock() -> some View {
        VStack {
            if let image = vm.profileImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .shadow(radius: 10)
                    .padding()
            } else {
                Circle()
                    .stroke(Color.csWelcome, lineWidth: 2)
                    .foregroundStyle(Color.white)
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .shadow(radius: 10)
                    .padding()
                    .overlay(alignment: .center) {
                        Image(systemName: "camera")
                            .font(.system(size: 30))
                            .foregroundColor(Color.csWelcomeColor)
                            .fontDesign(.rounded)
                            .padding()
                    }
                    .contentShape(Circle())
            }
        }
    }
    
    
    
    
    @ViewBuilder private func TextFieldsBlock() -> some View {
        VStack(alignment: .leading) {
            Text("Username")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(Color.gray)
                .padding(5)
            
            TextField("Username", text: $vm.username)
                .autocorrectionDisabled(true)
                .textfieldModifier()
                .autocapitalization(.none)
                .background(Color.csBackground)
                .cornerRadius(10)
            
            Text("Name")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(Color.gray)
                .padding(5)
            
            TextField("Name", text: $vm.nameField)
                .autocorrectionDisabled(true)
                .textfieldModifier()
                .autocapitalization(.none)
                .background(Color.csBackground)
                .cornerRadius(10)
        }
        .padding()
    }
}
