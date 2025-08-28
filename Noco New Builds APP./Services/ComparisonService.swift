//
//  ComparisonService.swift
//  Noco New Builds APP.
//
//  Created by mark leavitt on 8/27/25.
//

import Foundation
import Combine

class ComparisonService: ObservableObject {
    static let shared = ComparisonService()
    
    @Published var comparedBuilders: [Builder] = []
    @Published var isComparisonMode = false
    
    private init() {}
    
    // MARK: - Comparison Management
    func addToComparison(_ builder: Builder) {
        // Don't add if already in comparison or if we've reached the limit
        if !comparedBuilders.contains(where: { $0.id == builder.id }) && comparedBuilders.count < 3 {
            comparedBuilders.append(builder)
            
            // Enable comparison mode when we have builders to compare
            if !isComparisonMode && comparedBuilders.count > 0 {
                isComparisonMode = true
            }
        }
    }
    
    func removeFromComparison(_ builder: Builder) {
        comparedBuilders.removeAll { $0.id == builder.id }
        
        // Disable comparison mode if no builders left
        if comparedBuilders.isEmpty {
            isComparisonMode = false
        }
    }
    
    func toggleComparison(for builder: Builder) {
        if isInComparison(builder) {
            removeFromComparison(builder)
        } else {
            addToComparison(builder)
        }
    }
    
    func isInComparison(_ builder: Builder) -> Bool {
        return comparedBuilders.contains(where: { $0.id == builder.id })
    }
    
    func clearComparison() {
        comparedBuilders.removeAll()
        isComparisonMode = false
    }
    
    var canAddMore: Bool {
        return comparedBuilders.count < 3
    }
    
    var comparisonCount: Int {
        return comparedBuilders.count
    }
    
    // MARK: - Comparison Analytics
    func recordComparison() {
        // Track comparison interaction for analytics
        let builderIds = comparedBuilders.map { $0.id }
        let timestamp = Date()
        
        // In a real app, this would send to analytics service
        print("Comparison recorded: \(builderIds) at \(timestamp)")
    }
}

// MARK: - Comparison Data Structure
struct BuilderComparison {
    let builders: [Builder]
    let categories: [ComparisonCategory]
    
    init(builders: [Builder]) {
        self.builders = builders
        self.categories = ComparisonCategory.allCases
    }
}

enum ComparisonCategory: String, CaseIterable {
    case basicInfo = "Basic Information"
    case pricing = "Pricing"
    case communities = "Communities"
    case features = "Key Features"
    case contact = "Contact Information"
    
    func getComparisonRows(for builders: [Builder]) -> [ComparisonRow] {
        switch self {
        case .basicInfo:
            return [
                ComparisonRow(
                    label: "Builder Type",
                    values: builders.map { $0.category.displayName }
                ),
                ComparisonRow(
                    label: "Rating",
                    values: builders.map { $0.formattedRating }
                ),
                ComparisonRow(
                    label: "Reviews",
                    values: builders.map { $0.formattedReviewCount }
                ),
                ComparisonRow(
                    label: "Established",
                    values: builders.map { $0.established ?? "N/A" }
                )
            ]
            
        case .pricing:
            return [
                ComparisonRow(
                    label: "Price Range",
                    values: builders.map { $0.priceRange.formattedRange }
                ),
                ComparisonRow(
                    label: "Square Footage",
                    values: builders.map { 
                        $0.squareFootageRange?.formattedRange ?? "Contact builder"
                    }
                )
            ]
            
        case .communities:
            return [
                ComparisonRow(
                    label: "Total Communities",
                    values: builders.map { "\($0.communities.count)" }
                ),
                ComparisonRow(
                    label: "Active Communities",
                    values: builders.map { "\($0.activeCommunities)" }
                ),
                ComparisonRow(
                    label: "Primary Location",
                    values: builders.map { $0.location }
                )
            ]
            
        case .features:
            return [
                ComparisonRow(
                    label: "Key Specialties",
                    values: builders.map { 
                        $0.specialties.prefix(3).joined(separator: ", ") 
                    }
                ),
                ComparisonRow(
                    label: "Build on Your Lot",
                    values: builders.map { 
                        $0.buildOnYourLot == true ? "Yes" : "No"
                    }
                ),
                ComparisonRow(
                    label: "Warranty",
                    values: builders.map { $0.warranty ?? "Contact builder" }
                )
            ]
            
        case .contact:
            return [
                ComparisonRow(
                    label: "Website",
                    values: builders.map { $0.hasWebsite ? "Available" : "N/A" }
                ),
                ComparisonRow(
                    label: "Phone",
                    values: builders.map { $0.hasPhone ? "Available" : "N/A" }
                ),
                ComparisonRow(
                    label: "Email",
                    values: builders.map { $0.hasEmail ? "Available" : "N/A" }
                )
            ]
        }
    }
}

struct ComparisonRow {
    let label: String
    let values: [String]
}