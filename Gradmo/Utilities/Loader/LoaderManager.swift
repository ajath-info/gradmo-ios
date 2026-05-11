//
//  LoaderManager.swift
//  Motivaid
//
//  Created by Hrithik on 20/08/25.
//


import Foundation
import Combine
import SwiftUI
import UIKit

class LoaderManager: ObservableObject {
    
    static let shared = LoaderManager()
    @Published var isLoading: Bool = false
    private var activeRequestCount = 0
    
    init() {}
    
    func show() {
        DispatchQueue.main.async {
            self.activeRequestCount += 1
            self.isLoading = self.activeRequestCount > 0
            self.presentGlobalLoaderIfNeeded()
        }
    }
    
    func hide() {
        DispatchQueue.main.async {
            self.activeRequestCount = max(0, self.activeRequestCount - 1)
            self.isLoading = self.activeRequestCount > 0

            guard self.activeRequestCount == 0 else { return }
            LoaderHelper.shared.stopLoader()
        }
    }

    private func presentGlobalLoaderIfNeeded() {
        guard let view = activeWindow else { return }
        LoaderHelper.shared.startLoader(view, backGrounColor: UIColor.black.withAlphaComponent(0.12))
    }

    private var activeWindow: UIView? {
        let scenes = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive }

        let windows = scenes.flatMap(\.windows)

        if let keyWindow = windows.first(where: \.isKeyWindow) {
            return keyWindow
        }

        return windows.first
    }
}

extension View {
    func loadingOverlay(_ isLoading: Bool) -> some View {
        self.overlay {
            if isLoading {
                ZStack {
                    ProgressView("Please wait...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(10)
                        .foregroundStyle(.white)
                }.background(Color.clear)
            }
        }
        .allowsHitTesting(!isLoading)
    }
}
