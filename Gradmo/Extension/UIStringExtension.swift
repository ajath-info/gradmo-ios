//
//  UIStringExtension.swift
//  Motivaid
//
//  Created by Yogyata on 14/07/25.
//

import Foundation
import UIKit
extension UILabel {
    func setMultiText(text: [String], textFont: [UIFont], textColor: [UIColor], lineSpace: CGFloat = 13) {
        // Ensure input arrays have the same count
        guard text.count == textFont.count, text.count == textColor.count else {
            print("Error: The count of `text`, `textFont`, and `textColor` must be the same.")
            return
        }
        
        let modifiedText = NSMutableAttributedString()
        for i in 0..<text.count {
            let attributes: [NSAttributedString.Key: Any] = [
                .font: textFont[i],
                .foregroundColor: textColor[i]
            ]
            let attributedString = NSAttributedString(string: text[i], attributes: attributes)
            modifiedText.append(attributedString)
        }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpace
        modifiedText.addAttributes([.paragraphStyle: paragraphStyle], range: NSRange(location: 0, length: modifiedText.length))
        
        // Apply the attributed text to the label
        self.attributedText = modifiedText
        self.numberOfLines = 0 // Allow multiple lines
        self.textAlignment = .center
    }
    func addWhiteUnderline() {
        let attributedString = NSAttributedString(
            string: self.text ?? "",
            attributes: [
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .underlineColor: UIColor.white
            ]
        )
        self.attributedText = attributedString
    }
}

extension String {
    // Validation for email
    func isValidEmail() -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: self.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    // Validation for password (minimum 8 characters, at least 1 uppercase, 1 number, and 1 special character)
    func isValidPassword() -> Bool {
        let passwordRegex = "^(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z])(?=.*[!@#$&*]).{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: self.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    // Validation for name (no special characters, only letters and spaces)
    func isValidName() -> Bool {
        let nameRegex = "^[A-Za-z\\s]{1,50}$"
        return NSPredicate(format: "SELF MATCHES %@", nameRegex).evaluate(with: self.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    // Validation for phone number (10 digits only)
    func isValidPhoneNumber() -> Bool {
        let phoneRegex = "^[0-9]{10}$"
        return NSPredicate(format: "SELF MATCHES %@", phoneRegex).evaluate(with: self.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    // Normalizes indian mobile in +91 format for API payloads.
    func toIndiaPhoneNumber() -> String {
        let digits = components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        if digits.hasPrefix("91"), digits.count == 10 {
            return "\(digits)"
        }
        return "\(digits)"
    }
//    func toIndiaPhoneNumber() -> String {
//        let digits = components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
//        if digits.hasPrefix("91"), digits.count == 12 {
//            return "+\(digits)"
//        }
//        return "+91\(digits)"
//    }
    
    
    func toFormattedDateString(format: String = "MMMM dd, yyyy") -> String? {
        let inputDateFormatter = DateFormatter()
        inputDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ" // Input format from API (e.g., "2025-01-20T11:42:42.000Z")
        inputDateFormatter.timeZone = TimeZone(abbreviation: "UTC") // Time zone of the API data (assuming UTC)
        
        if let createdDate = inputDateFormatter.date(from: self) {
            let outputDateFormatter = DateFormatter()
            outputDateFormatter.dateFormat = format // Output format (e.g., "MMMM dd, yyyy")
            outputDateFormatter.timeZone = TimeZone.current // Local time zone
            
            return outputDateFormatter.string(from: createdDate)
        } else {
            print("Invalid date format")
            return nil
        }
    }
        
        // MARK: Convert ISO → "Fri, May 26 09:30 PM"
        func toReadableDateTime() -> String {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            
            guard let date = formatter.date(from: self) else { return self }
            
            let output = DateFormatter()
            output.dateFormat = "EEE, MMM d  hh:mm a"   // Fri, May 26  09:30 PM
            return output.string(from: date)
        }
        
        // MARK: Convert ISO → "Aug 2, 2025"
        func toReadableDate() -> String {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            
            guard let date = formatter.date(from: self) else { return self }
            
            let output = DateFormatter()
            output.dateFormat = "MMM d, yyyy"          // Aug 2, 2025
            return output.string(from: date)
        }
    
    // MARK: Convert ISO → "8:59 AM"
    func toReadableTime() -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        guard let date = formatter.date(from: self) else { return "" }

        let output = DateFormatter()
        output.locale = Locale(identifier: "en_US_POSIX")
        output.timeZone = TimeZone.current   // convert from UTC to local
        output.dateFormat = "h:mm a"         // 8:59 AM

        return output.string(from: date)
    }


    /// Converts ISO date string to weekday name (e.g., Monday, Tuesday)
       func toWeekday() -> String {
           let formatter = DateFormatter()
           formatter.locale = Locale(identifier: "en_US_POSIX")
           formatter.timeZone = TimeZone(secondsFromGMT: 0)
           formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

           guard let date = formatter.date(from: self) else { return "" }

           let weekdayFormatter = DateFormatter()
           weekdayFormatter.locale = Locale(identifier: "en_US_POSIX")
           weekdayFormatter.dateFormat = "EEEE" // Monday, Tuesday etc.

           return weekdayFormatter.string(from: date)
       }
    
    // MARK: Convert ISO → "Sun, Feb 08 6:44 AM"
    func toReadableDateTimeWithMeridiem() -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        guard let date = formatter.date(from: self) else { return self }

        let output = DateFormatter()
        output.locale = Locale(identifier: "en_US_POSIX")
        output.timeZone = TimeZone.current
        output.dateFormat = "EEE, MMM dd h:mm a"

        return output.string(from: date)
    }

}

struct GlobalFormatter {

    /// Convert dictionary keys into readable titles
    static func extractTitles(from dict: [String: Any]?) -> [String] {
        guard let dict = dict else { return [] }

        return dict.keys.map { key in
            key.replacingOccurrences(of: "_", with: " ")
                .capitalized
        }
    }
}
