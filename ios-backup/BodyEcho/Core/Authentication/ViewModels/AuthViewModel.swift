//
//  AuthViewModel.swift
//  BodyEcho
//
//  Created on 2025-11-10
//

import Foundation
import SwiftUI

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let authService = AuthService.shared

    init() {
        checkAuthStatus()
    }

    func checkAuthStatus() {
        isAuthenticated = authService.isAuthenticated
        if isAuthenticated {
            Task {
                await loadCurrentUser()
            }
        }
    }

    func signUp(fullName: String, email: String, password: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let user = try await authService.signUp(fullName: fullName, email: email, password: password)
            currentUser = user
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let user = try await authService.signIn(email: email, password: password)
            currentUser = user
            isAuthenticated = true
        } catch {
            errorMessage = "Giriş başarısız. E-posta veya şifrenizi kontrol edin."
        }

        isLoading = false
    }

    func signOut() {
        do {
            try authService.signOut()
            isAuthenticated = false
            currentUser = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func loadCurrentUser() async {
        do {
            currentUser = try await authService.getCurrentUser()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
