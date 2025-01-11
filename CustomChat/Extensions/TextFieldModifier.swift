//
//  TextFieldModifier.swift
//  CustomChat
//
//  Created by Muhammadjon Madaminov on 14/03/24.
//

import Foundation
import SwiftUI


extension View {
    func textfieldModifier() -> some View {
        modifier(MyTextFieldModifier())
    }
}


struct MyTextFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity)
            .frame(height: 55)
            .padding(.horizontal)
            .padding(.leading, 30)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}



extension View {
    func conditionalModifier<P:View, I:View>(_ condition: Bool, @ViewBuilder ifmodifier: @escaping ((_ content: I) -> P)) -> some View where I: View, P: View {
        modifier(ConditionalModifier(condition: condition, ifModifier: ifmodifier))
    }
}


struct ConditionalModifier<P: View, I: View>: ViewModifier {
    let condition: Bool
    let ifModifier: (_ content: I) -> P
    
    func body(content: Content) -> some View {
        if condition, let content = content as? I {
            ifModifier(content)
        } else {
            content
        }
    }
}
