//
//  User.swift
//  Noco New Builds APP.
//
//  Created by mark leavitt on 8/27/25.
//

import Foundation

struct User: Identifiable, Codable, Equatable {
    let id: String
    let email: String
    let firstName: String?
    let lastName: String?
    let phone: String?
    let profileImageUrl: String?
    let createdAt: Date
    let lastLoginAt: Date?
    let preferences: UserPreferences
    let leadData: LeadData?
    
    // MARK: - Computed Properties
    var isProfileComplete: Bool {
        return firstName != nil && 
               lastName != nil && 
               !email.isEmpty
    }
    
    var displayName: String {
        if let firstName = firstName, let lastName = lastName {
            return "\(firstName) \(lastName)"
        } else if let firstName = firstName {
            return firstName
        } else {
            return email
        }
    }
    
    var initials: String {
        let firstInitial = firstName?.first?.uppercased() ?? ""
        let lastInitial = lastName?.first?.uppercased() ?? ""
        return "\(firstInitial)\(lastInitial)"
    }
    
    var hasPhone: Bool {
        return phone != nil && !phone!.isEmpty
    }
    
    var formattedPhone: String? {
        guard let phone = phone else { return nil }
        
        // Basic phone formatting - can be enhanced
        let cleaned = phone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        if cleaned.count == 10 {
            let areaCode = String(cleaned.prefix(3))
            let middle = String(cleaned.dropFirst(3).prefix(3))
            let last = String(cleaned.suffix(4))
            return "(\(areaCode)) \(middle)-\(last)"
        }
        
        return phone
    }
}

// MARK: - Partial User (for incomplete registration)
struct PartialUser: Identifiable, Codable, Equatable {
    let id: String
    let email: String
    let firstName: String?
    let lastName: String?
    let profileImageUrl: String?
    
    func toCompleteUser(with registrationData: UserRegistrationData) -> User {
        return User(
            id: id,
            email: registrationData.email,
            firstName: registrationData.firstName,
            lastName: registrationData.lastName,
            phone: registrationData.phone,
            profileImageUrl: profileImageUrl,
            createdAt: Date(),
            lastLoginAt: Date(),
            preferences: UserPreferences(),
            leadData: LeadData(leadId: UUID().uuidString, source: registrationData.source)
        )
    }
}

// MARK: - User Preferences
struct UserPreferences: Codable, Equatable {
    var notifications: NotificationPreferences
    var search: SearchPreferences
    var privacy: PrivacyPreferences
    
    init() {
        self.notifications = NotificationPreferences()
        self.search = SearchPreferences()
        self.privacy = PrivacyPreferences()
    }
}

struct NotificationPreferences: Codable, Equatable {
    var pushNotifications: Bool = true
    var emailNotifications: Bool = true
    var newIncentives: Bool = true
    var priceChanges: Bool = true
    var newCommunities: Bool = true
    var marketingEmails: Bool = false
    
    var hasAnyNotificationsEnabled: Bool {
        return pushNotifications || emailNotifications || newIncentives || priceChanges || newCommunities
    }
}

struct SearchPreferences: Codable, Equatable {
    var defaultPriceRange: ClosedRange<Int>
    var preferredLocations: [String]
    var preferredBuilderTypes: [BuilderType]
    var preferredHomeTypes: [HomeType]
    var saveSearchHistory: Bool
    
    init() {
        self.defaultPriceRange = 300_000...700_000
        self.preferredLocations = []
        self.preferredBuilderTypes = []
        self.preferredHomeTypes = []
        self.saveSearchHistory = true
    }
    
    static func == (lhs: SearchPreferences, rhs: SearchPreferences) -> Bool {
        return lhs.defaultPriceRange.lowerBound == rhs.defaultPriceRange.lowerBound &&
               lhs.defaultPriceRange.upperBound == rhs.defaultPriceRange.upperBound &&
               lhs.preferredLocations == rhs.preferredLocations &&
               lhs.preferredBuilderTypes == rhs.preferredBuilderTypes &&
               lhs.preferredHomeTypes == rhs.preferredHomeTypes &&
               lhs.saveSearchHistory == rhs.saveSearchHistory
    }
}

struct PrivacyPreferences: Codable, Equatable {
    var shareDataWithPartners: Bool = false
    var allowAnalytics: Bool = true
    var allowLocationTracking: Bool = true
    var allowMarketingCommunications: Bool = false
}

// MARK: - Lead Data (matches web app CRM integration)
struct LeadData: Codable, Equatable {
    let leadId: String
    let source: String
    let createdAt: Date
    let lastInteractionAt: Date?
    let totalInteractions: Int
    let savedBuilders: [String] // Builder IDs
    let comparisonHistory: [ComparisonRecord]
    let searchHistory: [SearchRecord]
    
    init(leadId: String, source: String = "NoCo New Builds iOS App") {
        self.leadId = leadId
        self.source = source
        self.createdAt = Date()
        self.lastInteractionAt = nil
        self.totalInteractions = 0
        self.savedBuilders = []
        self.comparisonHistory = []
        self.searchHistory = []
    }
}

struct ComparisonRecord: Identifiable, Codable, Equatable {
    let id: String
    let builderIds: [String]
    let comparisonCriteria: String?
    let createdAt: Date
    let name: String?
    
    init(builderIds: [String], criteria: String? = nil, name: String? = nil) {
        self.id = UUID().uuidString
        self.builderIds = builderIds
        self.comparisonCriteria = criteria
        self.createdAt = Date()
        self.name = name
    }
}

struct SearchRecord: Identifiable, Codable, Equatable {
    let id: String
    let searchText: String
    let filters: String // JSON encoded filters
    let resultsCount: Int
    let createdAt: Date
    
    init(searchText: String, filters: String, resultsCount: Int) {
        self.id = UUID().uuidString
        self.searchText = searchText
        self.filters = filters
        self.resultsCount = resultsCount
        self.createdAt = Date()
    }
}

// MARK: - User Registration Data (matches web app registration flow)
struct UserRegistrationData {
    let firstName: String
    let lastName: String
    let email: String
    let phone: String?
    let source: String
    
    var isValid: Bool {
        return !firstName.isEmpty && 
               !lastName.isEmpty && 
               isValidEmail(email)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = #"^[^\s@]+@[^\s@]+\.[^\s@]+$"#
        return email.range(of: emailRegex, options: .regularExpression) != nil
    }
    
    // Convert to CRM lead format (matches web app API)
    func toCRMLeadData() -> CRMLeadData {
        return CRMLeadData(
            firstName: firstName,
            lastName: lastName,
            email: email,
            phone: phone,
            source: source,
            timestamp: ISO8601DateFormatter().string(from: Date())
        )
    }
}

// MARK: - CRM Lead Data (Codable for API)
struct CRMLeadData: Codable {
    let firstName: String
    let lastName: String
    let email: String
    let phone: String?
    let source: String
    let timestamp: String
}

// MARK: - Authentication State
enum AuthenticationState: Equatable {
    case unauthenticated
    case authenticating
    case authenticated(User)
    case registrationRequired(partialUser: PartialUser)
    
    var isAuthenticated: Bool {
        switch self {
        case .authenticated:
            return true
        default:
            return false
        }
    }
    
    var requiresRegistration: Bool {
        switch self {
        case .registrationRequired:
            return true
        default:
            return false
        }
    }
    
    var user: User? {
        switch self {
        case .authenticated(let user):
            return user
        default:
            return nil
        }
    }
    
    static func == (lhs: AuthenticationState, rhs: AuthenticationState) -> Bool {
        switch (lhs, rhs) {
        case (.unauthenticated, .unauthenticated):
            return true
        case (.authenticating, .authenticating):
            return true
        case (.authenticated(let lhsUser), .authenticated(let rhsUser)):
            return lhsUser == rhsUser
        case (.registrationRequired(let lhsPartial), .registrationRequired(let rhsPartial)):
            return lhsPartial == rhsPartial
        default:
            return false
        }
    }
}

struct PartialUser {
    let id: String
    let email: String
    let firstName: String?
    let lastName: String?
    let profileImageUrl: String?
    
    func toCompleteUser(with registrationData: UserRegistrationData) -> User {
        return User(
            id: id,
            email: registrationData.email,
            firstName: registrationData.firstName,
            lastName: registrationData.lastName,
            phone: registrationData.phone,
            profileImageUrl: profileImageUrl,
            createdAt: Date(),
            lastLoginAt: Date(),
            preferences: UserPreferences(),
            leadData: LeadData(leadId: UUID().uuidString)
        )
    }
}

// MARK: - Sample Data for Development
extension User {
    static let sampleUser = User(
        id: "sample-user-123",
        email: "john.doe@example.com",
        firstName: "John",
        lastName: "Doe",
        phone: "9705551234",
        profileImageUrl: nil,
        createdAt: Date().addingTimeInterval(-86400 * 30), // 30 days ago
        lastLoginAt: Date(),
        preferences: UserPreferences(),
        leadData: LeadData(leadId: "lead-123", source: "NoCo New Builds iOS App")
    )
    
    static let incompleteUser = User(
        id: "incomplete-user-456",
        email: "incomplete@example.com",
        firstName: nil,
        lastName: nil,
        phone: nil,
        profileImageUrl: nil,
        createdAt: Date(),
        lastLoginAt: Date(),
        preferences: UserPreferences(),
        leadData: nil
    )
}