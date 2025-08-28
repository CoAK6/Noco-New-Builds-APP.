//
//  Incentive.swift
//  Noco New Builds APP.
//
//  Created by mark leavitt on 8/27/25.
//

import Foundation

enum IncentiveType: String, CaseIterable, Codable {
    case rebate = "rebate"
    case taxCredit = "tax_credit"
    case discount = "discount"
    case financing = "financing"
    
    var displayName: String {
        switch self {
        case .rebate:
            return "Rebate"
        case .taxCredit:
            return "Tax Credit"
        case .discount:
            return "Discount"
        case .financing:
            return "Special Financing"
        }
    }
    
    var iconName: String {
        switch self {
        case .rebate:
            return "dollarsign.circle.fill"
        case .taxCredit:
            return "percent.circle.fill"
        case .discount:
            return "tag.fill"
        case .financing:
            return "creditcard.fill"
        }
    }
    
    var color: String {
        switch self {
        case .rebate:
            return "green"
        case .taxCredit:
            return "blue"
        case .discount:
            return "orange"
        case .financing:
            return "purple"
        }
    }
}

struct Incentive: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let type: IncentiveType
    let amount: Int
    let percentage: Double?
    let eligibility: [String]
    let expirationDate: String?
    let provider: String
    let category: String
    let location: String
    
    // MARK: - Computed Properties
    var hasExpirationDate: Bool {
        return expirationDate != nil
    }
    
    var formattedAmount: String {
        if amount > 0 {
            return "$\(amount.formatted(.number.notation(.compactName)))"
        } else if let percentage = percentage {
            return "\(percentage.formatted(.number.precision(.fractionLength(1))))%"
        } else {
            return "Special Offer"
        }
    }
    
    var formattedExpirationDate: String {
        guard let expirationDate = expirationDate else { return "" }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        if let date = formatter.date(from: expirationDate) {
            formatter.dateStyle = .medium
            return "Expires \(formatter.string(from: date))"
        }
        
        return "Expires \(expirationDate)"
    }
    
    var isExpiringSoon: Bool {
        guard let expirationDate = expirationDate else { return false }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = formatter.date(from: expirationDate) else { return false }
        
        let daysUntilExpiration = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
        return daysUntilExpiration <= 30 && daysUntilExpiration >= 0
    }
    
    var isExpired: Bool {
        guard let expirationDate = expirationDate else { return false }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = formatter.date(from: expirationDate) else { return false }
        
        return date < Date()
    }
    
    var daysUntilExpiration: Int? {
        guard let expirationDate = expirationDate else { return nil }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = formatter.date(from: expirationDate) else { return nil }
        
        return Calendar.current.dateComponents([.day], from: Date(), to: date).day
    }
    
    // MARK: - Search & Filter Support
    func matches(searchText: String) -> Bool {
        guard !searchText.isEmpty else { return true }
        
        let searchLower = searchText.lowercased()
        
        return title.lowercased().contains(searchLower) ||
               description.lowercased().contains(searchLower) ||
               provider.lowercased().contains(searchLower) ||
               category.lowercased().contains(searchLower) ||
               location.lowercased().contains(searchLower)
    }
    
    func matches(filters: IncentiveFilters) -> Bool {
        // Type filter
        if !filters.selectedTypes.isEmpty && !filters.selectedTypes.contains(type) {
            return false
        }
        
        // Provider filter
        if !filters.selectedProviders.isEmpty && !filters.selectedProviders.contains(provider) {
            return false
        }
        
        // Category filter
        if !filters.selectedCategories.isEmpty && !filters.selectedCategories.contains(category) {
            return false
        }
        
        // Location filter
        if !filters.selectedLocations.isEmpty && !filters.selectedLocations.contains(location) {
            return false
        }
        
        // Amount filter
        if amount < filters.minimumAmount {
            return false
        }
        
        // Expiring soon filter
        if filters.expiringSoonOnly && !isExpiringSoon {
            return false
        }
        
        // Hide expired filter
        if filters.hideExpired && isExpired {
            return false
        }
        
        return true
    }
}

// MARK: - Filter Support Model
struct IncentiveFilters {
    var selectedTypes: [IncentiveType] = []
    var selectedProviders: [String] = []
    var selectedCategories: [String] = []
    var selectedLocations: [String] = []
    var minimumAmount: Int = 0
    var expiringSoonOnly: Bool = false
    var hideExpired: Bool = true
    
    var hasActiveFilters: Bool {
        return !selectedTypes.isEmpty ||
               !selectedProviders.isEmpty ||
               !selectedCategories.isEmpty ||
               !selectedLocations.isEmpty ||
               minimumAmount > 0 ||
               expiringSoonOnly
    }
    
    mutating func clearAll() {
        selectedTypes = []
        selectedProviders = []
        selectedCategories = []
        selectedLocations = []
        minimumAmount = 0
        expiringSoonOnly = false
        hideExpired = true
    }
}

// MARK: - Sample Data for Development
extension Incentive {
    static let sampleIncentives = [
        Incentive(
            id: "dr-horton-1",
            title: "Special Interest Rate Promotion",
            description: "Special Interest Rate promos in Colorado; recent example shows 3.875% 7/6 ARM on select homes when using DHI Mortgage (contract/cutoff windows apply).",
            type: .financing,
            amount: 0,
            percentage: 3.875,
            eligibility: ["DHI Mortgage", "Select Homes", "Contract Windows Apply"],
            expirationDate: "2025-12-31",
            provider: "D.R. Horton",
            category: "Special Financing",
            location: "Multiple NoCo Communities (Johnstown, Severance, Wellington, Mead, Fort Lupton)"
        ),
        Incentive(
            id: "lennar-1",
            title: "Closing Cost Credit",
            description: "Up to $5,000 toward closing costs on select quick-move-ins when financing with Lennar Mortgage (limited time).",
            type: .rebate,
            amount: 5000,
            percentage: nil,
            eligibility: ["Quick Move-In Homes", "Lennar Mortgage"],
            expirationDate: "2025-12-31",
            provider: "Lennar",
            category: "Closing Cost Assistance",
            location: "Loveland (Riano Ridge), Johnstown (Ledge Rock)"
        ),
        Incentive(
            id: "richmond-1",
            title: "Northern Colorado Special Financing",
            description: "Northern Colorado special financing offers running with specific 8/18–8/24/2025 contract dates; also current ARM promo pages.",
            type: .financing,
            amount: 0,
            percentage: nil,
            eligibility: ["HomeAmerican Mortgage", "Funds Limited", "First-Come First-Served"],
            expirationDate: "2025-08-24",
            provider: "Richmond American",
            category: "Special Financing",
            location: "Multiple Northern Colorado Communities"
        )
    ]
}