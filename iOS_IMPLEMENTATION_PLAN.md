# NoCo New Builds iOS App - Implementation Plan

Based on the Product Requirements Document, this plan outlines the iOS-specific implementation strategy for the Northern Colorado Builder Directory mobile app.

## Project Overview
- **Platform:** iOS (SwiftUI)
- **Minimum iOS Version:** 16.0
- **Architecture:** MVVM with Combine
- **Data Layer:** Core Data + CloudKit (offline-first)
- **API Integration:** RESTful APIs to match web app backend

## Phase 1: Core Architecture & Foundation (Week 1-2)

### 1.1 Project Structure Setup
```
Noco New Builds APP/
├── Models/
│   ├── Builder.swift
│   ├── Community.swift
│   ├── Incentive.swift
│   └── User.swift
├── Views/
│   ├── Authentication/
│   ├── Builders/
│   ├── Geographic/
│   └── Incentives/
├── ViewModels/
│   ├── AuthViewModel.swift
│   ├── BuildersViewModel.swift
│   └── MapViewModel.swift
├── Services/
│   ├── APIService.swift
│   ├── AuthenticationService.swift
│   └── LocationService.swift
├── Utils/
│   ├── Extensions/
│   └── Constants.swift
└── Resources/
    ├── Assets.xcassets
    └── Info.plist
```

### 1.2 Core Data Models
- **Builder Entity:** Map from web TypeScript interfaces
- **Community Entity:** Include coordinates for mapping
- **User Entity:** Match Clerk user profile structure
- **Favorite Entity:** Track user saved builders

### 1.3 Networking Layer
- **APIService:** RESTful client to web app endpoints
- **Authentication:** OAuth integration (matching Clerk)
- **Offline Support:** Core Data caching strategy

## Phase 2: Authentication & User Registration (Week 3)

### 2.1 Registration Gate Implementation
```swift
// Matches web app UserRegistrationGate functionality
struct RegistrationGateView: View {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        if authViewModel.isAuthenticated && authViewModel.isProfileComplete {
            MainTabView()
        } else if authViewModel.isAuthenticated {
            ProfileCompletionView()
        } else {
            AuthenticationView()
        }
    }
}
```

### 2.2 Profile Completion Flow
- **Required Fields:** First Name, Last Name, Email (match web app)
- **CRM Integration:** API call to send-lead endpoint
- **Validation:** Real-time form validation

### 2.3 Authentication Service
```swift
class AuthenticationService: ObservableObject {
    @Published var user: User?
    @Published var isAuthenticated = false
    
    func signIn(email: String, password: String) async throws
    func signUp(email: String, password: String) async throws
    func completeProfile(firstName: String, lastName: String, email: String) async throws
    func signOut() async
}
```

## Phase 3: Builder Directory & Search (Week 4-5)

### 3.1 Builder List View
```swift
struct BuildersListView: View {
    @StateObject private var viewModel = BuildersViewModel()
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText)
                FilterView(filters: $viewModel.filters)
                
                LazyVStack {
                    ForEach(viewModel.filteredBuilders) { builder in
                        BuilderCardView(builder: builder)
                            .onTapGesture {
                                viewModel.selectBuilder(builder)
                            }
                    }
                }
            }
            .navigationTitle("Builders")
        }
    }
}
```

### 3.2 Builder Detail View
- **Hero Image:** Full-width builder image
- **Community Cards:** Scrollable horizontal list
- **Contact Actions:** Call, Website, Email buttons
- **Save/Favorite:** Heart icon with Core Data persistence

### 3.3 Search & Filtering
- **Search Bar:** Real-time text filtering
- **Filter Chips:** Price range, location, home types
- **Sort Options:** Name, rating, price
- **Filter Sheet:** Bottom sheet with advanced filters

### 3.4 Comparison Feature
```swift
struct ComparisonView: View {
    let selectedBuilders: [Builder]
    
    var body: some View {
        ScrollView(.horizontal) {
            LazyHGrid(rows: comparisonRows) {
                ForEach(selectedBuilders) { builder in
                    BuilderComparisonCard(builder: builder)
                }
            }
        }
    }
}
```

## Phase 4: Geographic View & Maps (Week 6)

### 4.1 Map Integration
```swift
import MapKit

struct GeographicView: View {
    @StateObject private var viewModel = MapViewModel()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 40.2677, longitude: -104.9778), // Fort Collins
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    )
    
    var body: some View {
        Map(coordinateRegion: $region, annotationItems: viewModel.communities) { community in
            MapAnnotation(coordinate: community.coordinate) {
                CommunityMapMarker(community: community)
            }
        }
        .overlay(
            MapControlsView()
                .padding()
            , alignment: .topTrailing
        )
    }
}
```

### 4.2 Custom Map Annotations
- **Builder Markers:** Custom pins with builder logos
- **Community Boundaries:** Polygon overlays for large communities
- **Clustering:** Group nearby markers at higher zoom levels

### 4.3 Location Services
```swift
class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var userLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    private let locationManager = CLLocationManager()
    
    func requestLocationPermission()
    func calculateDistances(to communities: [Community]) -> [Community]
}
```

## Phase 5: Incentives & Promotions (Week 7)

### 5.1 Incentives List View
```swift
struct IncentivesView: View {
    @StateObject private var viewModel = IncentivesViewModel()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.incentiveCategories, id: \.self) { category in
                    Section(category) {
                        ForEach(viewModel.incentives(for: category)) { incentive in
                            IncentiveCardView(incentive: incentive)
                        }
                    }
                }
            }
            .navigationTitle("Current Incentives")
            .refreshable {
                await viewModel.refreshIncentives()
            }
        }
    }
}
```

### 5.2 Incentive Detail Cards
- **Promotion Type:** Visual badges (Rebate, Financing, etc.)
- **Amount Display:** Prominent dollar amounts or percentages
- **Expiration Tracking:** Countdown timers for time-sensitive offers
- **Eligibility Requirements:** Collapsible requirement lists

## Phase 6: Core Features Integration (Week 8)

### 6.1 Tab Navigation
```swift
struct MainTabView: View {
    var body: some View {
        TabView {
            BuildersListView()
                .tabItem {
                    Image(systemName: "building.2")
                    Text("Builders")
                }
            
            GeographicView()
                .tabItem {
                    Image(systemName: "map")
                    Text("Map")
                }
            
            IncentivesView()
                .tabItem {
                    Image(systemName: "tag")
                    Text("Incentives")
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
        }
    }
}
```

### 6.2 User Profile & Settings
- **Saved Builders:** List of favorited builders
- **Comparison History:** Previous builder comparisons
- **Preferences:** Notification settings, search preferences
- **Account Management:** Profile editing, logout

### 6.3 Offline Support
```swift
class DataManager: ObservableObject {
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "NoCoBuilders")
        container.loadPersistentStores { _, error in
            if let error = error {
                print("Core Data error: \(error)")
            }
        }
        return container
    }()
    
    func saveContext()
    func syncWithServer() async
    func cacheBuilders(_ builders: [Builder])
}
```

## Technical Requirements

### Dependencies
```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.8.0"),
    .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.9.0"),
    .package(url: "https://github.com/apple/swift-log.git", from: "1.5.0")
]
```

### API Endpoints Integration
```swift
enum APIEndpoint {
    case builders
    case builderDetail(id: String)
    case incentives
    case sendLead
    
    var url: URL {
        switch self {
        case .builders:
            return baseURL.appendingPathComponent("/api/builders")
        case .builderDetail(let id):
            return baseURL.appendingPathComponent("/api/builders/\(id)")
        case .incentives:
            return baseURL.appendingPathComponent("/api/incentives")
        case .sendLead:
            return baseURL.appendingPathComponent("/api/send-lead")
        }
    }
}
```

### Environment Configuration
```swift
struct AppConfig {
    static let baseURL = URL(string: "https://your-vercel-app.vercel.app")!
    static let googleMapsAPIKey = "YOUR_GOOGLE_MAPS_API_KEY"
    static let clerkPublishableKey = "YOUR_CLERK_PUBLISHABLE_KEY"
}
```

## UI/UX Design Principles

### Design System
- **Colors:** Match web app brand colors
- **Typography:** SF Pro (iOS system font)
- **Spacing:** 8pt grid system
- **Components:** Reusable SwiftUI components

### Accessibility
- **VoiceOver:** Full screen reader support
- **Dynamic Type:** Support for larger text sizes
- **High Contrast:** Respect system accessibility settings
- **Haptic Feedback:** Tactile responses for interactions

### Performance Optimization
- **Lazy Loading:** Use LazyVStack and LazyHGrid
- **Image Caching:** Kingfisher for efficient image loading
- **Memory Management:** Proper view lifecycle management
- **Network Efficiency:** Request batching and caching

## Testing Strategy

### Unit Tests
```swift
class BuildersViewModelTests: XCTestCase {
    var viewModel: BuildersViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = BuildersViewModel()
    }
    
    func testFilterBuildersByPrice() {
        // Test filtering logic
    }
    
    func testSearchFunctionality() {
        // Test search implementation
    }
}
```

### UI Tests
- **Navigation Flow:** Test complete user journeys
- **Form Validation:** Registration form edge cases
- **Search Functionality:** Filter and search interactions
- **Map Interactions:** Geographic view testing

## Deployment Strategy

### App Store Preparation
1. **App Icons:** All required sizes (1024x1024 down to 16x16)
2. **Screenshots:** All device sizes and orientations
3. **App Description:** Match web app value proposition
4. **Keywords:** Northern Colorado, builders, new homes
5. **Privacy Policy:** Update for mobile data collection

### Version Management
- **Semantic Versioning:** Major.Minor.Patch
- **Feature Flags:** Progressive rollout of new features
- **A/B Testing:** Compare different UI approaches
- **Crash Reporting:** Comprehensive error tracking

This implementation plan provides a structured approach to building the iOS app while maintaining feature parity with the web application and leveraging iOS-specific capabilities like location services, push notifications, and offline support.