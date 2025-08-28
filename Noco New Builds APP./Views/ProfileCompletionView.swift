//
//  ProfileCompletionView.swift
//  Noco New Builds APP.
//
//  Created by mark leavitt on 8/27/25.
//

import SwiftUI

struct ProfileCompletionView: View {
    @EnvironmentObject var authService: AuthenticationService
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var errors: [String] = []
    @State private var isSubmitting = false
    @FocusState private var focusedField: Field?
    
    enum Field {
        case firstName, lastName, email, phone
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        Circle()
                            .fill(Color.blue.opacity(0.1))
                            .frame(width: 80, height: 80)
                            .overlay(
                                Image(systemName: "person.crop.circle.badge.plus")
                                    .font(.system(size: 40))
                                    .foregroundColor(.blue)
                            )
                        
                        Text("Complete Your Profile")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text("Please provide your information to access the builder directory and personalized features.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 20)
                    
                    // Form
                    VStack(spacing: 16) {
                        // First Name Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("First Name *")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            TextField("Enter your first name", text: $firstName)
                                .textFieldStyle(CustomTextFieldStyle())
                                .focused($focusedField, equals: .firstName)
                                .textContentType(.givenName)
                                .autocapitalization(.words)
                                .onSubmit { focusedField = .lastName }
                        }
                        
                        // Last Name Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Last Name *")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            TextField("Enter your last name", text: $lastName)
                                .textFieldStyle(CustomTextFieldStyle())
                                .focused($focusedField, equals: .lastName)
                                .textContentType(.familyName)
                                .autocapitalization(.words)
                                .onSubmit { focusedField = .email }
                        }
                        
                        // Email Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email Address *")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            HStack {
                                Image(systemName: "envelope")
                                    .foregroundColor(.secondary)
                                    .frame(width: 20)
                                
                                TextField("Enter your email address", text: $email)
                                    .textContentType(.emailAddress)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .autocorrectionDisabled()
                            }
                            .textFieldStyle(CustomTextFieldStyle())
                            .focused($focusedField, equals: .email)
                            .onSubmit { focusedField = .phone }
                        }
                        
                        // Phone Field (Optional)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Phone Number")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            HStack {
                                Image(systemName: "phone")
                                    .foregroundColor(.secondary)
                                    .frame(width: 20)
                                
                                TextField("(Optional) Phone number", text: $phone)
                                    .textContentType(.telephoneNumber)
                                    .keyboardType(.phonePad)
                            }
                            .textFieldStyle(CustomTextFieldStyle())
                            .focused($focusedField, equals: .phone)
                        }
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
                    
                    // Submit Button
                    Button(action: submitProfile) {
                        HStack {
                            if isSubmitting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                                
                                Text("Updating Profile...")
                            } else {
                                Text("Continue to Builder Directory")
                            }
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            isSubmitting ? Color.gray : Color.blue
                        )
                        .cornerRadius(12)
                    }
                    .disabled(isSubmitting)
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    
                    // Privacy Notice
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "lock.shield")
                                .foregroundColor(.secondary)
                                .font(.caption)
                            
                            Text("Your information is secure and will only be used to personalize your experience.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.leading)
                        }
                        
                        Text("* Required fields")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    
                    Spacer(minLength: 50)
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            // Pre-fill email if available from partial user
            if case .registrationRequired(let partialUser) = authService.authState {
                email = partialUser.email
                firstName = partialUser.firstName ?? ""
                lastName = partialUser.lastName ?? ""
            }
        }
    }
    
    private func submitProfile() {
        // Clear previous errors
        errors = []
        
        // Validate form
        let validation = UserRegistrationData.validate(
            firstName: firstName,
            lastName: lastName,
            email: email,
            phone: phone.isEmpty ? nil : phone
        )
        
        if !validation.isValid {
            errors = validation.errors
            return
        }
        
        // Create registration data
        let registrationData = UserRegistrationData(
            firstName: firstName.trimmingCharacters(in: .whitespacesAndNewlines),
            lastName: lastName.trimmingCharacters(in: .whitespacesAndNewlines),
            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
            phone: phone.isEmpty ? nil : phone.trimmingCharacters(in: .whitespacesAndNewlines),
            source: "NoCo New Builds iOS App"
        )
        
        // Submit profile
        isSubmitting = true
        
        Task {
            do {
                let partialUser = getPartialUser()
                try await authService.completeProfile(registrationData: registrationData, partialUser: partialUser)
                
                await MainActor.run {
                    isSubmitting = false
                    print("DEBUG: Profile completion successful, isSubmitting set to false")
                }
            } catch {
                await MainActor.run {
                    errors = [error.localizedDescription]
                    isSubmitting = false
                    print("DEBUG: Profile completion failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func getPartialUser() -> PartialUser? {
        if case .registrationRequired(let partialUser) = authService.authState {
            return partialUser
        }
        return nil
    }
}

// MARK: - Custom Text Field Style
struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
    }
}

#Preview {
    ProfileCompletionView()
        .environmentObject(AuthenticationService())
}