//
//  LoaderManager.swift
//  Motivaid
//
//  Created by Hrithik on 20/08/25.
//


import Foundation
import Combine
import SwiftUI

class LoaderManager: ObservableObject {
    
    static let shared = LoaderManager()
    @Published var isLoading: Bool = false
    
    init() {}
    
    func show() {
        DispatchQueue.main.async {
            self.isLoading = true
        }
    }
    
    func hide() {
        DispatchQueue.main.async {
            self.isLoading = false
        }
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
