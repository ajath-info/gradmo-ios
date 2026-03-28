//
//  TextFieldExtension.swift
//  Motivaid
//
//  Created by Yogyata on 14/07/25.
//

import Foundation
import UIKit
extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }

    func configureFormField(
        font: UIFont? = nil,
        leftPadding: CGFloat = 12,
        rightPadding: CGFloat? = nil,
        keyboardType: UIKeyboardType? = nil,
        delegate: UITextFieldDelegate? = nil,
        isSecureEntry: Bool? = nil
    ) {
        if let font {
            self.font = font
        }

        setLeftPaddingPoints(leftPadding)

        if let rightPadding {
            setRightPaddingPoints(rightPadding)
        }

        if let keyboardType {
            self.keyboardType = keyboardType
        }

        if let delegate {
            self.delegate = delegate
        }

        if let isSecureEntry {
            isSecureTextEntry = isSecureEntry
        }
    }

    func togglePasswordVisibility(using button: UIButton? = nil) {
        isSecureTextEntry.toggle()
        let imageName = isSecureTextEntry ? "eye.slash" : "eye"
        button?.setImage(UIImage(systemName: imageName), for: .normal)
    }
}


extension UITextField {
    func placeholderSet(placeHolder : String , color : UIColor) {
        self.attributedPlaceholder =  NSAttributedString(string: placeHolder,
                                                         attributes: [NSAttributedString.Key.foregroundColor:color])
    }
}
extension UITextField{
    func addDoneButtonOnKeyboard(){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40))
        doneToolbar.barStyle = .default

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))

        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()

        self.inputAccessoryView = doneToolbar
    }

     @objc func doneButtonAction(){
        self.resignFirstResponder()
    }
}


// MARK: - DOB Auto Formatting (DD/MM/YYYY)

private var dobDelegateKey: UInt8 = 0

extension UITextField {

    /// Enable automatic DD/MM/YYYY formatting + validation
    func enableDOBFormatting() {
        let delegate = DOBTextFieldDelegate()
        self.delegate = delegate
        objc_setAssociatedObject(self, &dobDelegateKey, delegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        self.keyboardType = .numberPad
    }
}


// MARK: - Private Delegate Class
//private class DOBTextFieldDelegate: NSObject, UITextFieldDelegate {
//
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//
//        if string.isEmpty { return true }  // Allow backspace
//
//        guard Int(string) != nil else { return false } // Only numbers
//
//        var current = textField.text ?? ""
//
//        if let r = Range(range, in: current) {
//            current.replaceSubrange(r, with: string)
//        }
//
//        let numbers = current.replacingOccurrences(of: "/", with: "")
//        if numbers.count > 8 { return false }
//
//        // MARK: Helper usage
//        func char(at index: Int) -> Character? {
//            guard index >= 0, index < numbers.count else { return nil }
//            return numbers[numbers.index(numbers.startIndex, offsetBy: index)]
//        }
//
//        func part(_ s: Int, _ e: Int) -> String {
//            guard s >= 0, e < numbers.count, s <= e else { return "" }
//            let start = numbers.index(numbers.startIndex, offsetBy: s)
//            let end = numbers.index(numbers.startIndex, offsetBy: e)
//            return String(numbers[start...end])
//        }
//
//        // ✅ Day first digit
//        if numbers.count >= 1 {
//            if let c = char(at: 0), c > "3" { return false }
//        }
//
//        // ✅ Full day (01–31)
//        if numbers.count >= 2 {
//            let day = Int(part(0, 1)) ?? 0
//            if !(1...31).contains(day) { return false }
//        }
//
//        // ✅ Month first digit
//        if numbers.count >= 3 {
//            if let c = char(at: 2), c > "1" { return false }
//        }
//
//        // ✅ Full month (01–12)
//        if numbers.count >= 4 {
//            let month = Int(part(2, 3)) ?? 0
//            if !(1...12).contains(month) { return false }
//        }
//
//        // ✅ Year first digit cannot be 0
//        if numbers.count >= 5 {
//            if let c = char(at: 4), c == "0" { return false }
//        }
//
//        // ✅ Year range validation
//        if numbers.count == 8 {
//            let year = Int(part(4, 7)) ?? 0
//            let currentYear = Calendar.current.component(.year, from: Date())
//            if !(1900...currentYear).contains(year) { return false }
//        }
//
//        // ✅ Format DD/MM/YYYY
//        var formatted = ""
//        for (i, char) in numbers.enumerated() {
//            if i == 2 || i == 4 { formatted.append("/") }
//            formatted.append(char)
//        }
//
//        textField.text = formatted
//        NotificationCenter.default.post(name: .dobUpdated, object: formatted)
//
//        return false
//    }
//}

private class DOBTextFieldDelegate: NSObject, UITextFieldDelegate {

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {

        if string.isEmpty { return true }          // Allow backspace
        guard Int(string) != nil else { return false } // Numbers only

        var current = textField.text ?? ""

        if let r = Range(range, in: current) {
            current.replaceSubrange(r, with: string)
        }

        let numbers = current.replacingOccurrences(of: "/", with: "")
        if numbers.count > 8 { return false }

        // Helpers
        func char(at index: Int) -> Character? {
            guard index >= 0, index < numbers.count else { return nil }
            return numbers[numbers.index(numbers.startIndex, offsetBy: index)]
        }

        func part(_ s: Int, _ e: Int) -> String {
            guard s >= 0, e < numbers.count, s <= e else { return "" }
            let start = numbers.index(numbers.startIndex, offsetBy: s)
            let end = numbers.index(numbers.startIndex, offsetBy: e)
            return String(numbers[start...end])
        }

        // ✅ Month first digit (0 or 1)
        if numbers.count >= 1 {
            if let c = char(at: 0), c > "1" { return false }
        }

        // ✅ Full month (01–12)
        if numbers.count >= 2 {
            let month = Int(part(0, 1)) ?? 0
            if !(1...12).contains(month) { return false }
        }

        // ✅ Day first digit (0–3)
        if numbers.count >= 3 {
            if let c = char(at: 2), c > "3" { return false }
        }

        // ✅ Full day (01–31)
        if numbers.count >= 4 {
            let day = Int(part(2, 3)) ?? 0
            if !(1...31).contains(day) { return false }
        }

        // ✅ Year first digit cannot be 0
        if numbers.count >= 5 {
            if let c = char(at: 4), c == "0" { return false }
        }

        // ✅ Year range validation
        if numbers.count == 8 {
            let year = Int(part(4, 7)) ?? 0
            let currentYear = Calendar.current.component(.year, from: Date())
            if !(1900...currentYear).contains(year) { return false }
        }

        // ✅ Format MM/DD/YYYY
        var formatted = ""
        for (i, char) in numbers.enumerated() {
            if i == 2 || i == 4 { formatted.append("/") }
            formatted.append(char)
        }

        textField.text = formatted
        NotificationCenter.default.post(name: .dobUpdated, object: formatted)

        return false
    }
}

extension Notification.Name {
    static let dobUpdated = Notification.Name("dobUpdated")
}

extension UITextView {
    /// Add left padding (points)
    func setLeftPaddingPoints(_ amount: CGFloat) {
        // For UITextView we change the textContainerInset's left value
        var inset = self.textContainerInset
        inset.left = amount
        self.textContainerInset = inset
    }

    /// Add right padding (points)
    func setRightPaddingPoints(_ amount: CGFloat) {
        var inset = self.textContainerInset
        inset.right = amount
        self.textContainerInset = inset
    }
}
