//
//  Utilities.swift
//  FireBaseBootcamp
//
//  Created by Muhammadjon Madaminov on 05/02/24.
//

import Foundation
import UIKit
import SwiftUI


final class Utilities {
    
    static let shared = Utilities()
    private init() { }
    
    @MainActor
    func topViewController(controller: UIViewController? = nil) -> UIViewController? {
        
        let controller = controller ?? UIApplication.shared.keyWindow?.rootViewController
        
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
    
}




struct ProfileImageView: View {
    let otherUser: UserModel?
    
    var body: some View {
        VStack {
            if let url = otherUser?.photoUrl {
                CustomImage(url: URL(string: url)) {
                    ProgressView()
//                        .frame(width: 50, height: 50)
                } imageView: { image in
                    image
                        .resizable()
                        .scaledToFill()
//                        .frame(width: 50, height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                }
            } else {
                RoundedRectangle(cornerRadius: 15)
//                    .frame(width: 50, height: 50)
                    .foregroundStyle(Color.green)
                    .overlay {
                        ZStack {
                            if let firstCharacter = otherUser?.name?.first {
                                Text(String(firstCharacter))
                            } else {
                                Text("U")
                            }
                        }
                        .font(.title.bold())
                    }
            }
        }
        .fontDesign(.rounded)
    }
}

