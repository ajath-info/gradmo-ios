//
//  KeyboardDismissWindow.swift
//  Gradmo
//
//  Created by Codex on 09/05/26.
//

import UIKit

final class KeyboardDismissWindow: UIWindow {
    override func sendEvent(_ event: UIEvent) {
        dismissKeyboardIfNeeded(for: event)
        super.sendEvent(event)
    }

    private func dismissKeyboardIfNeeded(for event: UIEvent) {
        guard
            event.type == .touches,
            let touch = event.allTouches?.first(where: { $0.phase == .began }),
            let firstResponder = findFirstResponder(),
            firstResponder is UITextField || firstResponder is UITextView,
            touchIsOutside(firstResponder, touch: touch)
        else {
            return
        }

        endEditing(true)
    }

    private func touchIsOutside(_ view: UIView, touch: UITouch) -> Bool {
        let point = touch.location(in: view)
        return !view.bounds.contains(point)
    }
}

private extension UIView {
    func findFirstResponder() -> UIView? {
        if isFirstResponder {
            return self
        }

        for subview in subviews {
            if let firstResponder = subview.findFirstResponder() {
                return firstResponder
            }
        }

        return nil
    }
}
