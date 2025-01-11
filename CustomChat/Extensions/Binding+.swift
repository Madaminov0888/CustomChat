//
//  Binding+.swift
//  CustomChat
//
//  Created by Muhammadjon Madaminov on 14/03/24.
//

import Foundation
import SwiftUI

extension Binding where Value == Bool {
    
    init<T>(value: Binding<T?>) {
        self.init {
            value.wrappedValue != nil
        } set: { newValue in
            value.wrappedValue = nil
        }

    }
    
}
