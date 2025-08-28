//
//  SignUpView.swift
//  Noco New Builds APP.
//
//  Created by mark leavitt on 8/27/25.
//

import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var authService = AuthenticationService()
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var agreeToTerms = false
    @State private var errors: [String] = []
    @FocusState private var focusedField: Field?
    
    enum Field {
        case email, password, confirmPassword
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "person.crop.circle.badge.plus")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("Create Account")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Join thousands of Northern Colorado home buyers")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // Sign Up Form
                    VStack(spacing: 20) {
                        // Email Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            HStack {
                                Image(systemName: "envelope")
                                    .foregroundColor(.secondary)
                                    .frame(width: 20)
                                
                                TextField("Enter your email", text: $email)
                                    .textContentType(.emailAddress)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .autocorrectionDisabled()
                            }
                            .textFieldStyle(CustomTextFieldStyle())
                            .focused($focusedField, equals: .email)
                            .onSubmit { focusedField = .password }
                        }
                        
                        // Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            HStack {
                                Image(systemName: "lock")
                                    .foregroundColor(.secondary)
                                    .frame(width: 20)
                                
                                SecureField("Create a password", text: $password)
                                    .textContentType(.newPassword)
                            }
                            .textFieldStyle(CustomTextFieldStyle())
                            .focused($focusedField, equals: .password)
                            .onSubmit { focusedField = .confirmPassword }
                            
                            // Password requirements
                            Text("Must be at least 8 characters")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        // Confirm Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Confirm Password")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            HStack {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(.secondary)
                                    .frame(width: 20)
                                
                                SecureField("Confirm your password", text: $confirmPassword)
                                    .textContentType(.newPassword)
                            }
                            .textFieldStyle(CustomTextFieldStyle())
                            .focused($focusedField, equals: .confirmPassword)
                            .onSubmit { signUp() }
                        }
                        
                        // Terms Agreement
                        HStack(alignment: .top, spacing: 12) {
                            Button(action: { agreeToTerms.toggle() }) {
                                Image(systemName: agreeToTerms ? "checkmark.square.fill" : "square")
                                    .foregroundColor(agreeToTerms ? .blue : .secondary)
                                    .font(.title3)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("I agree to the Terms of Service and Privacy Policy")
                                    .font(.caption)
                                    .foregroundColor(.primary)
                                
                                Text("By creating an account, you'll receive updates about new builders, incentives, and market insights.")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 24)
                    
                    // Error Messages
                    if !errors.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(errors, id: \.self) { error in
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.red)
                                        .font(.caption)
                                    
                                    Text(error)
                                        .font(.caption)
                                        .foregroundColor(.red)
                                    
                                    Spacer()
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                        .padding(.horizontal, 24)
                    }
                    
                    // Sign Up Button
                    Button(action: signUp) {
                        HStack {
                            if authService.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                                
                                Text("Creating Account...")
                            } else {
                                Text("Create Account")
                            }
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            (authService.isLoading || !canSignUp) ? Color.gray : Color.blue
                        )
                        .cornerRadius(12)
                    }
                    .disabled(authService.isLoading || !canSignUp)
                    .padding(.horizontal, 24)
                    
                    // Sign In Link
                    HStack {
                        Text("Already have an account?")
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        Button("Sign In") {
                            dismiss()
                        }
                        .font(.body)
                        .foregroundColor(.blue)
                    }
                    .padding(.top, 16)
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .onChange(of: authService.authState) { newState in
            if case .registrationRequired = newState {
                dismiss()
            }
        }
    }
    
    private var canSignUp: Bool {
        return !email.isEmpty && 
               !password.isEmpty && 
               !confirmPassword.isEmpty && 
               agreeToTerms
    }
    
    private func signUp() {
        // Clear previous errors
        errors = []
        
        // Validate form
        var validationErrors: [String] = []
        
        // Email validation
        let emailRegex = #"^[^\s@]+@[^\s@]+\.[^\s@]+$"#
        if email.isEmpty {
            validationErrors.append("Email is required")
        } else if email.range(of: emailRegex, options: .regularExpression) == nil {
            validationErrors.append("Please enter a valid email address")
        }
        
        // Password validation
        if password.isEmpty {
            validationErrors.append("Password is required")
        } else if password.count < 8 {
            validationErrors.append("Password must be at least 8 characters")
        }
        
        // Confirm password validation
        if confirmPassword.isEmpty {
            validationErrors.append("Please confirm your password")
        } else if password != confirmPassword {
            validationErrors.append("Passwords do not match")
        }
        
        // Terms agreement validation
        if !agreeToTerms {
            validationErrors.append("Please agree to the Terms of Service")
        }
        
        if !validationErrors.isEmpty {
            errors = validationErrors
            return
        }
        
        // Proceed with sign up
        Task {
            do {
                try await authService.signUp(email: email, password: password)
            } catch {
                await MainActor.run {
                    errors = [error.localizedDescription]
                }
            }
        }
    }
}

#Preview {
    SignUpView()
}