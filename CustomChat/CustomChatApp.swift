//
//  CustomChatApp.swift
//  CustomChat
//
//  Created by Muhammadjon Madaminov on 29/02/24.
//
import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
      print("Firebase configured")
    return true
  }
}


@main
struct CustomChatApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                RootView()
                    .preferredColorScheme(.light)
            }
        }
        .defaultSize(width: 500, height: 800)
    }
}
