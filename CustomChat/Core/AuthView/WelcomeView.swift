//
//  WelcomeView.swift
//  CustomChat
//
//  Created by Muhammadjon Madaminov on 29/02/24.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift
import CryptoKit
import _AuthenticationServices_SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var vm: AuthViewModel

    @State private var passwd2: String = ""
    
    @State private var code: String = ""
    @AppStorage("isAuthed") private var showRegisterView: Bool = false
    @State private var showAlert: Bool = false
    
    
    var body: some View {
        ZStack {
            if vm.profileSetUp {
                RegisterView()
            } else {
                LoginRegisterPage()
            }
        }
        .alert(Text("Passwords do not match. Please make sure the passwords match in both fields"), isPresented: $showAlert, actions: {
            Text("Try again")
        })
        .animation(.spring, value: vm.authPickerValue)
        .transition(.scale)
        .onAppear(perform: {
            UISegmentedControl.appearance().backgroundColor = .white
            UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(Color.csWelcomeColor)
            let colors: [NSAttributedString.Key: Any] = [
                .foregroundColor : UIColor.white
            ]
            UISegmentedControl.appearance().setTitleTextAttributes(colors, for: .selected)
        })
    }
}



extension WelcomeView {
    @ViewBuilder private func LoginRegisterPage() -> some View {
        VStack {
            WelcomeTitle()
            
            VStack(spacing: 20) {
                
                AuthPicker()
                
                
                TextField("Email..", text: $vm.email)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
                    .textfieldModifier()
                
                
                SecureField("Password", text: $vm.passwd)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
                    .textfieldModifier()
                
                
                SecureField("Password", text: $passwd2)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
                    .textfieldModifier()
                    .opacity(vm.authPickerValue == .singIn ? 0 : 1)
                
                
                SubmitButton()
                
                
                Divider()
                
                GoogleSignInButton(scheme: .dark, style: .standard, state: .normal) {
                    Task {
                        await vm.signInWithGoogleFunc()
                        self.showRegisterView = true
                    }
                }
                
                SignInWithAppleButton { request in
                    
                } onCompletion: { completion in
                    
                }
                .frame(maxWidth: .infinity)
                .frame(height: 55)


            }
            .padding(.vertical, 30)
            .padding(.horizontal)
            .glassBlurView(.white)
            .padding()
            
        }
    }
}


enum AuthPickerValue: String, Hashable {
    case singIn = "Sign In"
    case signUp = "Sign Up"
}


#Preview {
    ZStack {
        BackgroundView(changeOfView: .constant(true))
            .ignoresSafeArea()
        
        WelcomeView()
            .environmentObject(AuthViewModel())
    }
}






extension WelcomeView {
    
    
    @ViewBuilder private func SubmitButton() -> some View {
        Button(action: {
            if vm.authPickerValue == .singIn {
                vm.signInWithEmail(email: self.vm.email, password: self.vm.passwd)
                self.showRegisterView = true
            } else {
                if vm.passwd == passwd2 {
//                    vm.signUpWithEmail(email: email, password: passwd)
//                    self.showRegisterView = true
                    vm.profileSetUp = true
                } else {
                    showAlert.toggle()
                }
            }
        }, label: {
            Text("Getting started")
                .foregroundStyle(Color.white)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .frame(height: 55)
                .background(Color.accentColor)
                .clipShape(RoundedRectangle(cornerRadius: 20))
        })
    }
    
    
    @ViewBuilder private func WelcomeTitle() -> some View {
        Text("Welcome")
            .font(.system(size: 46))
            .fontWeight(.heavy)
            .foregroundStyle(Color.csWelcomeColor)
            .fontDesign(.rounded)
            .padding(.top)
    }
    
    
    @ViewBuilder private func AuthPicker() -> some View {
        Text(vm.authPickerValue.rawValue)
            .font(.title)
            .fontWeight(.bold)
            .foregroundStyle(Color.csWelcomeColor)
            .animation(.none, value: vm.authPickerValue)
        
        Picker(selection: $vm.authPickerValue) {
            Text("Sign Up")
                .tag(AuthPickerValue.signUp)
            Text("Sign In")
                .tag(AuthPickerValue.singIn)
        } label: {}
        .pickerStyle(SegmentedPickerStyle())
    }
    
}
