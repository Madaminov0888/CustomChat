//
//  AuthView.swift
//  CustomChat
//
//  Created by Muhammadjon Madaminov on 29/02/24.
//

import SwiftUI
import Firebase
import FirebaseAuth



struct AuthView: View {
    
    @StateObject private var vm: AuthViewModel = AuthViewModel()
    @AppStorage("isAuthed") private var isAuthed: Bool = false
    
    var body: some View {
        ZStack {
            BackgroundView(changeOfView: .constant(false))
                .ignoresSafeArea()
            
            ScrollView {
                WelcomeView()
                    .scrollIndicators(.never)
            }
            
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
                        vm.signUpWithEmail()
                        self.isAuthed = true
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
                            vm.profileSetUp = false
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
        .environmentObject(vm)
    }
}

#Preview {
    NavigationStack {
        AuthView()
    }
}




extension AuthView {
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
