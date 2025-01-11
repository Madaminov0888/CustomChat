//
//  TransparentBlurModifier.swift
//  AdvancedBootCamp
//
//  Created by Muhammadjon Madaminov on 29/11/23.
//

import SwiftUI

extension View {
    
    public func glassBlurView(_ color: Color = Color(#colorLiteral(red: 0.1311095953, green: 0.121230863, blue: 0.2308914959, alpha: 1)).opacity(0.5), _ cRadius: CGFloat = 20) -> some View {
        modifier(TransparentBlurModifier(color: color, cRadius: cRadius))
    }
}


//    .cornerRadius(25, corners: [.topLeft, .topRight])

struct TransparentBlurModifier: ViewModifier {
    let color: Color
    let cRadius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .background(
                TransparentBlurView()
                    .blur(radius: 9, opaque: true)
                    .background(color.opacity(0.2))
                    .shadow(radius: 10, y: 5)
            )
            .cornerRadius(cRadius)
            .overlay {
                RoundedRectangle(cornerRadius: cRadius)
                    .stroke(.white.opacity(0.25), lineWidth: 2)
                    
            }
    }
}
