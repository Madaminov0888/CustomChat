//
//  String+.swift
//  CustomChat
//
//  Created by Muhammadjon Madaminov on 16/06/24.
//

import Foundation

extension String {
    func formatDateFromApi() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSXXX"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.date(from: self) ?? Date()
    }
}
