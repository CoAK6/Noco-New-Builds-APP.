//
//  ContentView.swift
//  Noco New Builds APP.
//
//  Created by mark leavitt on 8/27/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authService = AuthenticationService()
    
    var body: some View {
        Group {
            switch authService.authState {
            case .unauthenticated:
                WelcomeView()
                    .environmentObject(authService)
            case .authenticating:
                VStack {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.blue)
                    
                    Text("Authenticating...")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding(.top)
                    
                    Text("Current State: Authenticating")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
            case .authenticated(let user):
                if user.isProfileComplete {
                    MainTabView()
                        .environmentObject(authService)
                } else {
                    VStack {
                        Text("DEBUG: User authenticated but profile incomplete")
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding()
                        
                        ProfileCompletionView()
                            .environmentObject(authService)
                    }
                }
            case .registrationRequired:
                VStack {
                    Text("DEBUG: Registration required state")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .padding()
                    
                    ProfileCompletionView()
                        .environmentObject(authService)
                }
            }
        }
    }
}

// MARK: - Welcome View (for unauthenticated users)
struct WelcomeView: View {
    @State private var showingSignIn = false
    @State private var showingSignUp = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.blue.opacity(0.6), Color.blue.opacity(0.9)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Logo/Icon
                VStack(spacing: 16) {
                    Image(systemName: "building.2.crop.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.white)
                    
                    Text("NoCo New Builds")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Northern Colorado Builder Directory")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
                
                // Features highlights
                VStack(alignment: .leading, spacing: 16) {
                    FeatureRow(icon: "magnifyingglass", text: "Search & compare builders")
                    FeatureRow(icon: "map", text: "Explore communities on map")
                    FeatureRow(icon: "tag.fill", text: "Track current incentives")
                    FeatureRow(icon: "heart.fill", text: "Save favorite builders")
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                // Action buttons
                VStack(spacing: 16) {
                    Button(action: { showingSignUp = true }) {
                        Text("Get Started")
                            .font(.headline)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                    }
                    
                    Button(action: { showingSignIn = true }) {
                        Text("Sign In")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white, lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal, 32)
                
                Spacer()
            }
        }
        .sheet(isPresented: $showingSignIn) {
            SignInView()
        }
        .sheet(isPresented: $showingSignUp) {
            SignUpView()
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.white)
                .frame(width: 24)
            
            Text(text)
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
            
            Spacer()
        }
    }
}

// MARK: - Loading View
struct LoadingView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.blue)
            
            Text(message)
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

// MARK: - Main Tab View (for authenticated users)
struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            BuildersListView()
                .tabItem {
                    Image(systemName: "building.2")
                    Text("Builders")
                }
                .tag(0)
            
            GeographicView()
                .tabItem {
                    Image(systemName: "map")
                    Text("Map")
                }
                .tag(1)
            
            IncentivesView()
                .tabItem {
                    Image(systemName: "tag")
                    Text("Incentives")
                }
                .tag(2)
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
                .tag(3)
        }
        .tint(.blue)
    }
}

// MARK: - Placeholder Views (to be implemented)

struct GeographicView: View {
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "map.circle")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                
                Text("Geographic View")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Interactive map coming soon...")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Map")
        }
    }
}

struct IncentivesView: View {
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "tag.circle")
                    .font(.system(size: 60))
                    .foregroundColor(.orange)
                
                Text("Current Incentives")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Promotions and offers coming soon...")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Incentives")
        }
    }
}

struct ProfileView: View {
    @EnvironmentObject var authService: AuthenticationService
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let user = authService.currentUser {
                    VStack(spacing: 16) {
                        // Profile image placeholder
                        Circle()
                            .fill(Color.blue.opacity(0.1))
                            .frame(width: 80, height: 80)
                            .overlay(
                                Text(user.initials)
                                    .font(.title)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.blue)
                            )
                        
                        Text(user.displayName)
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text(user.email)
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        if let phone = user.formattedPhone {
                            Text(phone)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top)
                    
                    // Profile stats
                    VStack(spacing: 12) {
                        if let leadData = user.leadData {
                            HStack {
                                VStack {
                                    Text("\(leadData.savedBuilders.count)")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.blue)
                                    
                                    Text("Saved Builders")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                VStack {
                                    Text("\(leadData.comparisonHistory.count)")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.green)
                                    
                                    Text("Comparisons")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                VStack {
                                    Text("\(leadData.totalInteractions)")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.orange)
                                    
                                    Text("Interactions")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                    }
                }
                
                Spacer()
                
                Button("Sign Out") {
                    authService.signOut()
                }
                .foregroundColor(.red)
                .padding(.bottom)
            }
            .navigationTitle("Profile")
        }
    }
}

// MARK: - Authentication Placeholder Views



#Preview {
    ContentView()
}
