//
//  UIViewExtension.swift
//  Motivaid
//
//  Created by Yogyata on 14/07/25.
//

import Foundation
import UIKit
import SwiftUI
extension UIViewController{
    func getTimeOffset() -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ZZZZZ"
        let timeoffset = dateFormatter.string(from: Date())
        return timeoffset
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
}
extension UIView {
    
    func setCornerRadius(radius: CGFloat = 10) {
        self.layer.masksToBounds = false
        self.layer.cornerRadius = radius
        self.clipsToBounds = true
        self.layer.shadowRadius = 6
    }

    func topRoundCorners(radius: CGFloat = 30) {
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.layer.cornerRadius = radius
    }

    func provideCornerRadius(corners: CACornerMask, radius: CGFloat) {
        self.layer.maskedCorners = corners
        self.layer.cornerRadius = radius
    }
    
    func applyGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        
        gradientLayer.colors = [
            UIColor(red: 0x63/255, green: 0x97/255, blue: 0xEE/255, alpha: 1).cgColor, // #6397EE
            UIColor(red: 0x5E/255, green: 0xAD/255, blue: 0xF2/255, alpha: 1).cgColor, // #5EADF2
            UIColor(red: 0x50/255, green: 0xC4/255, blue: 0xF2/255, alpha: 1).cgColor  // #50C4F2
        ]
        
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)   // top-left
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)     // bottom-right
        gradientLayer.cornerRadius = self.layer.cornerRadius
        
        self.layer.insertSublayer(gradientLayer, at: 0)
    }

    func applyCapsuleCornerRadius() {
        layer.cornerRadius = frame.height / 2
        clipsToBounds = true
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = 25.0
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}


extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

extension UIButton {
    func applyGradientToTitle() {
        // Ensure layout is done before rendering gradient
        self.layoutIfNeeded()
        guard let titleLabel = self.titleLabel, let text = titleLabel.text, !text.isEmpty else { return }
        
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 0x63/255, green: 0x97/255, blue: 0xEE/255, alpha: 1).cgColor, // #6397EE
            UIColor(red: 0x5E/255, green: 0xAD/255, blue: 0xF2/255, alpha: 1).cgColor, // #5EADF2
            UIColor(red: 0x50/255, green: 0xC4/255, blue: 0xF2/255, alpha: 1).cgColor  // #50C4F2
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.frame = titleLabel.bounds
        
        // Create image from gradient
        UIGraphicsBeginImageContextWithOptions(gradient.bounds.size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        gradient.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if let image = image {
            self.setTitleColor(UIColor(patternImage: image), for: .normal)
        }
    }

    func setEnabledStyle(_ isEnabled: Bool, enabledAlpha: CGFloat = 1.0, disabledAlpha: CGFloat = 0.5) {
        self.isEnabled = isEnabled
        alpha = isEnabled ? enabledAlpha : disabledAlpha
    }
}

extension UIViewController {

    func presentDatePicker(
        title: String,
        minimumDate: Date? = Date(),
        maximumDate: Date? = nil,
        mode: UIDatePicker.Mode = .date,
        minOffsetDays: Int = 0,                // 👈 NEW
        completion: @escaping (Date) -> Void
    ) {
        
        let alert = UIAlertController(title: title, message: "\n\n\n\n\n\n", preferredStyle: .actionSheet)
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = mode
        datePicker.preferredDatePickerStyle = .wheels
        
        // Apply minimum date offset
        if let minDate = minimumDate {
            let finalMin = Calendar.current.date(byAdding: .day, value: minOffsetDays, to: minDate)
            datePicker.minimumDate = finalMin   // 👈 Now minimum date includes the 1-day offset
        } else {
            datePicker.minimumDate = nil
        }
        
        datePicker.maximumDate = maximumDate
        
        datePicker.frame = CGRect(x: 0, y: 15, width: alert.view.bounds.width - 20, height: 160)
        alert.view.addSubview(datePicker)
        
        alert.addAction(UIAlertAction(title: "Done", style: .default) { _ in
            completion(datePicker.date)
        })
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = self.view
            popover.sourceRect = CGRect(
                x: self.view.bounds.midX,
                y: self.view.bounds.midY,
                width: 0,
                height: 0
            )
            popover.permittedArrowDirections = []
        }
        
        present(alert, animated: true)
    }

    
    
    func applyBlur(
        to view: UIView,
        blurAlpha: CGFloat = 0.2,                      // User controls blur strength
        style: UIBlurEffect.Style = .systemMaterial    // User can pick blur style
    ) {
        // Remove old blur views before applying new one
        view.subviews.forEach {
            if $0 is UIVisualEffectView { $0.removeFromSuperview() }
        }

        let blurEffect = UIBlurEffect(style: style)
        let blurView = UIVisualEffectView(effect: blurEffect)

        blurView.frame = view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.layer.cornerRadius = view.layer.cornerRadius
        blurView.clipsToBounds = true

        blurView.alpha = blurAlpha       // 👈 User-controlled blur power
        blurView.backgroundColor = .clear   // 👈 100% transparent background

        view.insertSubview(blurView, at: 0)
    }

    
}


extension Date {
    func toYMD() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: self)
    }
}


extension UIViewController {
    
    func datePickerForPastDates(
        to textField: UITextField,
        mode: UIDatePicker.Mode = .date,
        maximumDate: Date? = Date(),     // Prevent future DOB by default
        minimumDate: Date? = nil,
        format: String = "MM/dd/yyyy",
        onDone: ((String) -> Void)? = nil
    ) {
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = mode
        datePicker.maximumDate = maximumDate
        datePicker.minimumDate = minimumDate
        datePicker.preferredDatePickerStyle = .wheels
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let done = UIBarButtonItem(title: "Done", style: .plain, target: nil, action: nil)
        let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: #selector(dismissKeyboard))
        let space = UIBarButtonItem(systemItem: .flexibleSpace)
        
        done.actionHandler { [weak self] _ in
            guard let self = self else { return }
            
            let formatter = DateFormatter()
            formatter.dateFormat = format
            let dateString = formatter.string(from: datePicker.date)
            
            textField.text = dateString
            onDone?(dateString)     // send back selected date
            
            self.view.endEditing(true)
        }
        
        toolbar.setItems([cancel, space, done], animated: true)
        
        textField.inputView = datePicker
        textField.inputAccessoryView = toolbar
    }

    func datePickerForFutureDates(
        to textField: UITextField,
        mode: UIDatePicker.Mode = .date,
        format: String = "MM/dd/yyyy",
        onDone: ((String) -> Void)? = nil
    ) {
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = mode
        datePicker.minimumDate = Date()
        datePicker.preferredDatePickerStyle = .wheels
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let done = UIBarButtonItem(title: "Done", style: .plain, target: nil, action: nil)
        let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: #selector(dismissKeyboard))
        let space = UIBarButtonItem(systemItem: .flexibleSpace)
        
        done.actionHandler { [weak self] _ in
            guard let self = self else { return }
            let formatter = DateFormatter()
            formatter.dateFormat = format
            let dateString = formatter.string(from: datePicker.date)
            textField.text = dateString
            onDone?(dateString)
            self.view.endEditing(true)
        }
        
        toolbar.setItems([cancel, space, done], animated: true)
        textField.inputView = datePicker
        textField.inputAccessoryView = toolbar
    }
    
    func datePicker(
         to textField: UITextField,
         mode: UIDatePicker.Mode = .date,
         format: String = "MM/dd/yyyy",
         onDone: ((String) -> Void)? = nil
     ) {
         
         let datePicker = UIDatePicker()
         datePicker.datePickerMode = mode
         datePicker.preferredDatePickerStyle = .wheels

         let toolbar = UIToolbar()
         toolbar.sizeToFit()

         let done = UIBarButtonItem(title: "Done", style: .plain, target: nil, action: nil)
         let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(dismissKeyboard))
         let space = UIBarButtonItem(systemItem: .flexibleSpace)

         done.actionHandler { [weak self] _ in
             let formatter = DateFormatter()
             formatter.dateFormat = format
             let dateString = formatter.string(from: datePicker.date)
             textField.text = dateString
             onDone?(dateString)
             self?.view.endEditing(true)
         }

         toolbar.setItems([cancel, space, done], animated: true)

         textField.inputView = datePicker
         textField.inputAccessoryView = toolbar
     }

}

private var barButtonActionKey: UInt8 = 0

extension UIBarButtonItem {
    func actionHandler(action: @escaping (UIBarButtonItem) -> Void) {
        objc_setAssociatedObject(self, &barButtonActionKey, action, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        target = self
        self.action = #selector(triggerActionHandler)
    }

    @objc func triggerActionHandler() {
        if let action = objc_getAssociatedObject(self, &barButtonActionKey) as? ((UIBarButtonItem) -> Void) {
            action(self)
        }
    }
}

extension UIViewController {

    /// Shows a native toast, dismissing the keyboard first.
    func showToastSafely(_ message: String, duration: TimeInterval = 2.0) {
        view.endEditing(true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.view.showNativeToast(message, duration: duration, bottomOffset: 40)
        }
    }

    /// Shows a native toast positioned above the keyboard.
    func showToastAboveKeyboard(_ message: String,
                                keyboardHeight: CGFloat,
                                duration: TimeInterval = 2.0) {
        view.showNativeToast(message, duration: duration, bottomOffset: keyboardHeight + 20)
    }
}

extension UIView {

    /// Displays a simple native toast label anchored near the bottom of the view.
    func showNativeToast(_ message: String,
                         duration: TimeInterval = 2.0,
                         bottomOffset: CGFloat = 40) {
        // Remove any existing toast
        subviews.filter { $0.tag == 99991 }.forEach { $0.removeFromSuperview() }

        let toastLabel = UILabel()
        toastLabel.tag = 99991
        toastLabel.text = message
        toastLabel.textColor = .white
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont.systemFont(ofSize: 14)
        toastLabel.numberOfLines = 0
        toastLabel.layer.cornerRadius = 12
        toastLabel.clipsToBounds = true
        toastLabel.alpha = 0

        let padding: CGFloat = 16
        let maxWidth = bounds.width - 60
        let size = toastLabel.sizeThatFits(CGSize(width: maxWidth, height: .greatestFiniteMagnitude))
        let toastWidth = min(size.width + padding * 2, maxWidth)
        let toastHeight = size.height + padding

        toastLabel.frame = CGRect(
            x: (bounds.width - toastWidth) / 2,
            y: bounds.height - bottomOffset - toastHeight,
            width: toastWidth,
            height: toastHeight
        )

        addSubview(toastLabel)

        UIView.animate(withDuration: 0.3, animations: {
            toastLabel.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: duration, options: .curveEaseOut, animations: {
                toastLabel.alpha = 0
            }) { _ in
                toastLabel.removeFromSuperview()
            }
        }
    }
}


import UIKit

extension UIViewController {

    func showAlert(title: String = "Gradmo", message: String) {

        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "OK",
                                      style: .default))

        self.present(alert, animated: true)
    }
}
