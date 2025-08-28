//
//  Builder.swift
//  Noco New Builds APP.
//
//  Created by mark leavitt on 8/27/25.
//

import Foundation
import CoreLocation

// MARK: - Enums matching web app types
enum BuilderCategory: String, CaseIterable, Codable {
    case national = "National"
    case regional = "Regional" 
    case localCustom = "Local Custom"
    
    var displayName: String { rawValue }
}

enum BuilderType: String, CaseIterable, Codable {
    case production = "Production"
    case luxury = "Luxury"
    case semiCustom = "Semi-Custom"
    case custom = "Custom"
    case townhomes = "Townhomes"
    
    var displayName: String { rawValue }
}

enum CommunityStatus: String, CaseIterable, Codable {
    case active = "Active"
    case comingSoon = "Coming Soon"
    case finalPhase = "Final Phase"
    case soldOut = "Sold Out"
    case preSales = "Pre-Sales"
    
    var displayName: String { rawValue }
}

enum HomeType: String, CaseIterable, Codable {
    case singleFamily = "Single-Family"
    case pairedHomes = "Paired Homes"
    case townhomes = "Townhomes"
    case patioHomes = "Patio Homes"
    case condos = "Condos"
    case villas = "Villas"
    
    var displayName: String { rawValue }
}

// MARK: - Supporting Models
struct PriceRange: Codable {
    let min: Int
    let max: Int
    
    var formattedRange: String {
        return "$\(min.formatted(.number.notation(.compactName))) - $\(max.formatted(.number.notation(.compactName)))"
    }
}

struct SquareFootageRange: Codable {
    let min: Int
    let max: Int
    
    var formattedRange: String {
        return "\(min.formatted()) - \(max.formatted()) sq ft"
    }
}

struct CorporateInfo: Codable {
    let headquarters: String?
    let founded: String?
    let publicCompany: Bool?
    let stockTicker: String?
}

struct CommunityDetails: Identifiable, Codable {
    let id: String
    let name: String
    let city: String
    let status: CommunityStatus
    let homeTypes: [HomeType]
    let priceRange: PriceRange?
    let squareFootageRange: SquareFootageRange?
    let url: String?
    let description: String?
    let collections: [String]?
    let launchDate: String?
    let amenities: [String]?
    let lotSizes: String?
    let nearbyAttractions: [String]?
    let coordinates: Coordinates?
    
    struct Coordinates: Codable {
        let lat: Double
        let lng: Double
        
        var clLocationCoordinate: CLLocationCoordinate2D {
            return CLLocationCoordinate2D(latitude: lat, longitude: lng)
        }
    }
}

// MARK: - Main Builder Model
struct Builder: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let location: String
    let category: BuilderCategory
    let builderType: [BuilderType]
    let priceRange: PriceRange
    let rating: Double
    let reviewCount: Int
    let specialties: [String]
    let imageUrl: String
    let logoUrl: String?
    let website: String?
    let phone: String?
    let email: String?
    let communities: [CommunityDetails]
    let warranty: String?
    let squareFootageRange: SquareFootageRange?
    let established: String?
    let buildingStyles: [String]?
    let currentIncentives: String?
    let buildOnYourLot: Bool?
    let yearlyHomes: Int?
    let servesCounties: [String]?
    let corporateInfo: CorporateInfo?
    
    // MARK: - Computed Properties
    var hasWebsite: Bool { website != nil }
    var hasPhone: Bool { phone != nil }
    var hasEmail: Bool { email != nil }
    var hasCurrentIncentives: Bool { currentIncentives != nil && !currentIncentives!.isEmpty }
    
    var formattedRating: String {
        return String(format: "%.1f", rating)
    }
    
    var formattedReviewCount: String {
        if reviewCount >= 1000 {
            return "\(reviewCount / 1000)k+ reviews"
        } else {
            return "\(reviewCount) reviews"
        }
    }
    
    var primaryLocation: CLLocationCoordinate2D? {
        return communities.first?.coordinates?.clLocationCoordinate
    }
    
    var allCities: [String] {
        return Array(Set(communities.map { $0.city })).sorted()
    }
    
    var availableHomeTypes: [HomeType] {
        let allHomeTypes = communities.flatMap { $0.homeTypes }
        return Array(Set(allHomeTypes)).sorted { $0.displayName < $1.displayName }
    }
    
    // MARK: - Search & Filter Support
    func matches(searchText: String) -> Bool {
        guard !searchText.isEmpty else { return true }
        
        let searchLower = searchText.lowercased()
        
        return name.lowercased().contains(searchLower) ||
               description.lowercased().contains(searchLower) ||
               location.lowercased().contains(searchLower) ||
               specialties.contains { $0.lowercased().contains(searchLower) } ||
               communities.contains { $0.name.lowercased().contains(searchLower) || $0.city.lowercased().contains(searchLower) }
    }
    
    func matches(filters: BuilderFilters) -> Bool {
        // Location filter
        if !filters.selectedCities.isEmpty {
            let builderCities = Set(allCities)
            let filterCities = Set(filters.selectedCities)
            if builderCities.intersection(filterCities).isEmpty {
                return false
            }
        }
        
        // Price range filter
        let minPrice = filters.priceRange.lowerBound
        let maxPrice = filters.priceRange.upperBound
        if priceRange.max < minPrice || priceRange.min > maxPrice {
            return false
        }
        
        // Category filter
        if !filters.selectedCategories.isEmpty && !filters.selectedCategories.contains(category) {
            return false
        }
        
        // Builder type filter
        if !filters.selectedBuilderTypes.isEmpty {
            let hasMatchingType = builderType.contains { filters.selectedBuilderTypes.contains($0) }
            if !hasMatchingType {
                return false
            }
        }
        
        // Home type filter
        if !filters.selectedHomeTypes.isEmpty {
            let hasMatchingHomeType = availableHomeTypes.contains { filters.selectedHomeTypes.contains($0) }
            if !hasMatchingHomeType {
                return false
            }
        }
        
        // Build on your lot filter
        if let buildOnYourLotFilter = filters.buildOnYourLot {
            if buildOnYourLot != buildOnYourLotFilter {
                return false
            }
        }
        
        // Rating filter
        if rating < filters.minimumRating {
            return false
        }
        
        return true
    }
}

// MARK: - Filter Support Model
struct BuilderFilters {
    var selectedCities: [String] = []
    var priceRange: ClosedRange<Int> = 200_000...1_000_000
    var selectedCategories: [BuilderCategory] = []
    var selectedBuilderTypes: [BuilderType] = []
    var selectedHomeTypes: [HomeType] = []
    var buildOnYourLot: Bool? = nil
    var minimumRating: Double = 0.0
    
    var hasActiveFilters: Bool {
        return !selectedCities.isEmpty ||
               priceRange != 200_000...1_000_000 ||
               !selectedCategories.isEmpty ||
               !selectedBuilderTypes.isEmpty ||
               !selectedHomeTypes.isEmpty ||
               buildOnYourLot != nil ||
               minimumRating > 0.0
    }
    
    mutating func clearAll() {
        selectedCities = []
        priceRange = 200_000...1_000_000
        selectedCategories = []
        selectedBuilderTypes = []
        selectedHomeTypes = []
        buildOnYourLot = nil
        minimumRating = 0.0
    }
}

// MARK: - Sample Data for Development
extension Builder {
    static let sampleBuilder = Builder(
        id: "1",
        name: "D.R. Horton",
        description: "America's largest homebuilder offering affordable quality homes with modern amenities and flexible financing options.",
        location: "Johnstown",
        category: .national,
        builderType: [.production],
        priceRange: PriceRange(min: 320000, max: 480000),
        rating: 4.2,
        reviewCount: 203,
        specialties: ["Affordable Quality", "Flexible Financing", "Modern Amenities", "First-Time Buyers"],
        imageUrl: "/images/dr-horton.jpg",
        logoUrl: "/logos/dr-horton-logo.svg",
        website: "https://drhorton.com",
        phone: "(970) 555-0123",
        email: "info@drhorton.com",
        communities: [
            CommunityDetails(
                id: "revere-johnstown",
                name: "Revere at Johnstown",
                city: "Johnstown",
                status: .active,
                homeTypes: [.singleFamily, .pairedHomes],
                priceRange: PriceRange(min: 320000, max: 480000),
                squareFootageRange: SquareFootageRange(min: 1200, max: 2800),
                url: "https://www.drhorton.com/colorado/denver/johnstown/revere-at-johnstown",
                description: "Master-planned community with modern amenities and flexible floor plans",
                collections: ["Express", "Freedom", "Emerald"],
                launchDate: "2024",
                amenities: ["Community Pool", "Playground", "Walking Trails"],
                lotSizes: "0.1 - 0.25 acres",
                nearbyAttractions: ["St. Vrain State Park", "Johnstown Town Center"],
                coordinates: CommunityDetails.Coordinates(lat: 40.3308, lng: -104.9108)
            )
        ],
        warranty: "10-year structural warranty",
        squareFootageRange: SquareFootageRange(min: 1200, max: 3500),
        established: "1978",
        buildingStyles: ["Contemporary", "Traditional", "Ranch"],
        currentIncentives: "Special Interest Rate promo - 3.875% 7/6 ARM",
        buildOnYourLot: false,
        yearlyHomes: 1200,
        servesCounties: ["Weld", "Larimer", "Boulder"],
        corporateInfo: CorporateInfo(
            headquarters: "Arlington, TX",
            founded: "1978",
            publicCompany: true,
            stockTicker: "DHI"
        )
    )
    
    static let sampleBuilders = [sampleBuilder]
}

// MARK: - Price Range Categories for Filtering
enum PriceRangeCategory: String, CaseIterable, Codable {
    case budget = "under_400k"
    case midRange = "400k_600k"
    case upperMid = "600k_800k"
    case luxury = "800k_plus"
    
    var displayName: String {
        switch self {
        case .budget:
            return "Under $400K"
        case .midRange:
            return "$400K - $600K"
        case .upperMid:
            return "$600K - $800K"
        case .luxury:
            return "$800K+"
        }
    }
    
    var range: ClosedRange<Int> {
        switch self {
        case .budget:
            return 0...399_999
        case .midRange:
            return 400_000...599_999
        case .upperMid:
            return 600_000...799_999
        case .luxury:
            return 800_000...Int.max
        }
    }
    
    func contains(priceRange: PriceRange) -> Bool {
        let builderRange = priceRange.min...priceRange.max
        return range.overlaps(builderRange)
    }
}