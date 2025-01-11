//
//  JSONDecoder+.swift
//  CustomChat
//
//  Created by Muhammadjon Madaminov on 16/03/24.
//

import Foundation
import SwiftUI

extension JSONDecoder {
    func convertDictionaryToJSON(_ dictionary: [String: Any]) -> String? {
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted) else {
            print("Something is wrong while converting dictionary to JSON data.")
            return nil
        }
        
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            print("Something is wrong while converting JSON data to JSON string.")
            return nil
        }
        
        return jsonString
    }
}
