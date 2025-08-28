//
//  AuthenticationService.swift
//  Noco New Builds APP.
//
//  Created by mark leavitt on 8/27/25.
//

import Foundation
import Combine

class AuthenticationService: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var authState: AuthenticationState = .unauthenticated
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let apiService = APIService.shared
    private let keychain = KeychainService.shared
    
    init() {
        checkStoredAuthentication()
    }
    
    // MARK: - Authentication State Management
    private func checkStoredAuthentication() {
        // Check if we have stored credentials
        if let storedUser = keychain.getStoredUser() {
            currentUser = storedUser
            authState = .authenticated(storedUser)
            isAuthenticated = true
        } else {
            authState = .unauthenticated
            isAuthenticated = false
        }
    }
    
    // MARK: - Sign Up
    func signUp(email: String, password: String) async throws {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
            authState = .authenticating
        }
        
        do {
            // In a real implementation, this would make an API call to your auth provider
            // For now, we'll simulate the process
            try await simulateNetworkDelay()
            
            // Create partial user that needs profile completion
            let partialUser = PartialUser(
                id: UUID().uuidString,
                email: email,
                firstName: nil,
                lastName: nil,
                profileImageUrl: nil
            )
            
            await MainActor.run {
                authState = .registrationRequired(partialUser: partialUser)
                isLoading = false
            }
            
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                authState = .unauthenticated
                isLoading = false
            }
            throw error
        }
    }
    
    // MARK: - Sign In
    func signIn(email: String, password: String) async throws {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
            authState = .authenticating
        }
        
        do {
            // Simulate API call
            try await simulateNetworkDelay()
            
            // Check if this is a returning user with complete profile
            if let existingUser = getExistingUser(email: email) {
                // Update last login time
                let updatedUser = User(
                    id: existingUser.id,
                    email: existingUser.email,
                    firstName: existingUser.firstName,
                    lastName: existingUser.lastName,
                    phone: existingUser.phone,
                    profileImageUrl: existingUser.profileImageUrl,
                    createdAt: existingUser.createdAt,
                    lastLoginAt: Date(), // Update login time
                    preferences: existingUser.preferences,
                    leadData: existingUser.leadData
                )
                
                await MainActor.run {
                    currentUser = updatedUser
                    authState = .authenticated(updatedUser)
                    isAuthenticated = true
                    isLoading = false
                }
                
                // Store updated user credentials
                keychain.storeUser(updatedUser)
                
            } else {
                // New user or user without complete profile - check if we have a partial user stored
                if let storedUser = keychain.getStoredUser(),
                   storedUser.email.lowercased() == email.lowercased(),
                   !storedUser.isProfileComplete {
                    // User exists but profile is incomplete
                    let partialUser = PartialUser(
                        id: storedUser.id,
                        email: storedUser.email,
                        firstName: storedUser.firstName,
                        lastName: storedUser.lastName,
                        profileImageUrl: storedUser.profileImageUrl
                    )
                    
                    await MainActor.run {
                        authState = .registrationRequired(partialUser: partialUser)
                        isLoading = false
                    }
                } else {
                    // Completely new user
                    let partialUser = PartialUser(
                        id: UUID().uuidString,
                        email: email,
                        firstName: nil,
                        lastName: nil,
                        profileImageUrl: nil
                    )
                    
                    await MainActor.run {
                        authState = .registrationRequired(partialUser: partialUser)
                        isLoading = false
                    }
                }
            }
            
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                authState = .unauthenticated
                isLoading = false
            }
            throw error
        }
    }
    
    // MARK: - Profile Completion
    func completeProfile(registrationData: UserRegistrationData, partialUser: PartialUser?) async throws {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            // Validate registration data
            guard registrationData.isValid else {
                throw AuthenticationError.invalidRegistrationData
            }
            
            // Send lead to CRM (matching web app functionality)
            try await sendLeadToCRM(registrationData)
            
            // Create complete user
            let completeUser = partialUser?.toCompleteUser(with: registrationData) ?? 
                               createNewUser(from: registrationData)
            
            await MainActor.run {
                currentUser = completeUser
                authState = .authenticated(completeUser)
                isAuthenticated = true
                isLoading = false
            }
            
            // Store user credentials
            keychain.storeUser(completeUser)
            
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isLoading = false
            }
            throw error
        }
    }
    
    // MARK: - Sign Out
    func signOut() {
        currentUser = nil
        authState = .unauthenticated
        isAuthenticated = false
        errorMessage = nil
        
        // Clear stored credentials
        keychain.clearStoredCredentials()
    }
    
    // MARK: - Helper Methods
    private func simulateNetworkDelay() async throws {
        // Simulate network call delay
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
    }
    
    private func sendLeadToCRM(_ registrationData: UserRegistrationData) async throws {
        // Send lead to CRM using API service (matching web app)
        try await withCheckedThrowingContinuation { continuation in
            apiService.sendLead(registrationData)
                .sink(
                    receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            continuation.resume()
                        case .failure(let error):
                            continuation.resume(throwing: error)
                        }
                    },
                    receiveValue: { response in
                        print("Lead sent to CRM: \(response.leadId)")
                    }
                )
                .store(in: &cancellables)
        }
    }
    
    private func getExistingUser(email: String) -> User? {
        // Check if we have a stored user with this email
        if let storedUser = keychain.getStoredUser() {
            print("DEBUG: Found stored user - Email: \(storedUser.email), Profile Complete: \(storedUser.isProfileComplete)")
            
            if storedUser.email.lowercased() == email.lowercased() && storedUser.isProfileComplete {
                print("DEBUG: Existing user found and profile is complete")
                return storedUser
            } else {
                print("DEBUG: Stored user found but either email doesn't match or profile incomplete")
                print("DEBUG: Stored email: \(storedUser.email), Sign-in email: \(email)")
                print("DEBUG: Profile complete: \(storedUser.isProfileComplete)")
            }
        } else {
            print("DEBUG: No stored user found in keychain")
        }
        
        // In a real app, this would also check your backend API
        // For now, only check locally stored users
        return nil
    }
    
    private func createNewUser(from registrationData: UserRegistrationData) -> User {
        return User(
            id: UUID().uuidString,
            email: registrationData.email,
            firstName: registrationData.firstName,
            lastName: registrationData.lastName,
            phone: registrationData.phone,
            profileImageUrl: nil,
            createdAt: Date(),
            lastLoginAt: Date(),
            preferences: UserPreferences(),
            leadData: LeadData(leadId: UUID().uuidString, source: registrationData.source)
        )
    }
    
    // MARK: - Password Reset
    func resetPassword(email: String) async throws {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            try await simulateNetworkDelay()
            // In real implementation, would call password reset API
            
            await MainActor.run {
                isLoading = false
            }
            
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isLoading = false
            }
            throw error
        }
    }
}

// MARK: - Authentication Errors
enum AuthenticationError: LocalizedError {
    case invalidCredentials
    case invalidRegistrationData
    case networkError
    case userNotFound
    case emailAlreadyExists
    case weakPassword
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password"
        case .invalidRegistrationData:
            return "Please fill in all required fields"
        case .networkError:
            return "Network connection error"
        case .userNotFound:
            return "User not found"
        case .emailAlreadyExists:
            return "An account with this email already exists"
        case .weakPassword:
            return "Password must be at least 8 characters"
        }
    }
}

// MARK: - Keychain Service for Secure Storage
class KeychainService {
    static let shared = KeychainService()
    private init() {}
    
    private let userKey = "stored_user"
    private let service = "com.noconewbuilds.app"
    
    func storeUser(_ user: User) {
        guard let userData = try? JSONEncoder().encode(user) else { return }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: userKey,
            kSecValueData as String: userData
        ]
        
        // Delete existing item first
        SecItemDelete(query as CFDictionary)
        
        // Add new item
        SecItemAdd(query as CFDictionary, nil)
    }
    
    func getStoredUser() -> User? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: userKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let user = try? JSONDecoder().decode(User.self, from: data) else {
            return nil
        }
        
        return user
    }
    
    func clearStoredCredentials() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: userKey
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}

// MARK: - Form Validation Helpers
extension UserRegistrationData {
    static func validate(firstName: String, lastName: String, email: String, phone: String?) -> (isValid: Bool, errors: [String]) {
        var errors: [String] = []
        
        // First name validation
        if firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append("First name is required")
        }
        
        // Last name validation
        if lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append("Last name is required")
        }
        
        // Email validation
        let emailRegex = #"^[^\s@]+@[^\s@]+\.[^\s@]+$"#
        if email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append("Email is required")
        } else if email.range(of: emailRegex, options: .regularExpression) == nil {
            errors.append("Please enter a valid email address")
        }
        
        // Phone validation (optional but format check if provided)
        if let phone = phone, !phone.isEmpty {
            let phoneRegex = #"^\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$"#
            if phone.range(of: phoneRegex, options: .regularExpression) == nil {
                errors.append("Please enter a valid phone number")
            }
        }
        
        return (isValid: errors.isEmpty, errors: errors)
    }
}