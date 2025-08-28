//
//  SignInView.swift
//  Noco New Builds APP.
//
//  Created by mark leavitt on 8/27/25.
//

import SwiftUI

struct SignInView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var authService = AuthenticationService()
    @State private var email = ""
    @State private var password = ""
    @State private var showingForgotPassword = false
    @FocusState private var focusedField: Field?
    
    enum Field {
        case email, password
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "person.crop.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("Welcome Back")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Sign in to access your saved builders and comparisons")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 40)
                    
                    // Sign In Form
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
                                
                                SecureField("Enter your password", text: $password)
                                    .textContentType(.password)
                            }
                            .textFieldStyle(CustomTextFieldStyle())
                            .focused($focusedField, equals: .password)
                            .onSubmit { signIn() }
                        }
                        
                        // Forgot Password Button
                        HStack {
                            Spacer()
                            Button("Forgot Password?") {
                                showingForgotPassword = true
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // Error Message
                    if let errorMessage = authService.errorMessage {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(.red)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                        .padding(.horizontal, 24)
                    }
                    
                    // Sign In Button
                    Button(action: signIn) {
                        HStack {
                            if authService.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                                
                                Text("Signing In...")
                            } else {
                                Text("Sign In")
                            }
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(authService.isLoading ? Color.gray : Color.blue)
                        .cornerRadius(12)
                    }
                    .disabled(authService.isLoading || email.isEmpty || password.isEmpty)
                    .padding(.horizontal, 24)
                    
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
        .alert("Reset Password", isPresented: $showingForgotPassword) {
            TextField("Email", text: $email)
            Button("Send Reset Email") {
                sendPasswordReset()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Enter your email address to receive a password reset link.")
        }
        .onChange(of: authService.authState) { newState in
            if case .authenticated = newState {
                dismiss()
            } else if case .registrationRequired = newState {
                dismiss()
            }
        }
    }
    
    private func signIn() {
        guard !email.isEmpty, !password.isEmpty else { return }
        
        Task {
            do {
                try await authService.signIn(email: email, password: password)
                print("DEBUG: Sign in successful")
            } catch {
                await MainActor.run {
                    print("DEBUG: Sign in failed with error: \(error)")
                }
            }
        }
    }
    
    private func sendPasswordReset() {
        guard !email.isEmpty else { return }
        
        Task {
            try await authService.resetPassword(email: email)
        }
    }
}

#Preview {
    SignInView()
}