//
//  BuilderDetailView.swift
//  Noco New Builds APP.
//
//  Created by mark leavitt on 8/27/25.
//

import SwiftUI
import MapKit

struct BuilderDetailView: View {
    let builder: Builder
    @State private var selectedTab: DetailTab = .overview
    @Environment(\.dismiss) var dismiss
    
    enum DetailTab: String, CaseIterable {
        case overview = "Overview"
        case communities = "Communities"
        case incentives = "Incentives"
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Header Section
                VStack(alignment: .leading, spacing: 16) {
                    // Builder Logo and Basic Info
                    HStack(alignment: .top, spacing: 16) {
                        AsyncImage(url: URL(string: builder.logoUrl ?? "")) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .overlay(
                                    Text(builder.name.prefix(2).uppercased())
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                )
                        }
                        .frame(width: 80, height: 80)
                        .cornerRadius(12)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(builder.name)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text(builder.category.displayName)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text(builder.priceRange.formattedRange)
                                .font(.subheadline)
                                .foregroundColor(.blue)
                                .fontWeight(.semibold)
                            
                            if let websiteUrl = builder.websiteUrl {
                                Link("Visit Website", destination: URL(string: websiteUrl)!)
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        Spacer()
                    }
                    
                    // Quick Stats
                    HStack(spacing: 20) {
                        StatView(
                            icon: "building.2",
                            value: "\(builder.communities.count)",
                            label: "Communities"
                        )
                        
                        if let activeCommunities = builder.activeCommunities {
                            StatView(
                                icon: "checkmark.circle.fill",
                                value: "\(activeCommunities)",
                                label: "Active"
                            )
                        }
                        
                        if let incentives = builder.currentIncentives {
                            StatView(
                                icon: "tag.fill",
                                value: "\(incentives.count)",
                                label: "Incentives"
                            )
                        }
                        
                        Spacer()
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                
                // Tab Selector
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        ForEach(DetailTab.allCases, id: \.self) { tab in
                            Button(action: { selectedTab = tab }) {
                                VStack(spacing: 4) {
                                    Text(tab.rawValue)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(selectedTab == tab ? .blue : .secondary)
                                    
                                    Rectangle()
                                        .fill(selectedTab == tab ? Color.blue : Color.clear)
                                        .frame(height: 2)
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .background(Color(.systemGray6))
                }
                
                // Tab Content
                Group {
                    switch selectedTab {
                    case .overview:
                        OverviewTabView(builder: builder)
                    case .communities:
                        CommunitiesTabView(builder: builder)
                    case .incentives:
                        IncentivesTabView(builder: builder)
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { /* Add to favorites */ }) {
                    Image(systemName: "heart")
                        .foregroundColor(.blue)
                }
            }
        }
    }
}

// MARK: - Overview Tab
struct OverviewTabView: View {
    let builder: Builder
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Description
            if let description = builder.description {
                VStack(alignment: .leading, spacing: 8) {
                    Text("About")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(description)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
            
            // Key Features
            if let features = builder.features, !features.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Key Features")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 8) {
                        ForEach(features, id: \.self) { feature in
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.caption)
                                
                                Text(feature)
                                    .font(.caption)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                    }
                }
            }
            
            // Coverage Area Map (placeholder)
            VStack(alignment: .leading, spacing: 12) {
                Text("Coverage Area")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray5))
                    .frame(height: 200)
                    .overlay(
                        VStack {
                            Image(systemName: "map")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                            
                            Text("Northern Colorado")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    )
            }
        }
        .padding()
    }
}

// MARK: - Communities Tab
struct CommunitiesTabView: View {
    let builder: Builder
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(builder.communities) { community in
                CommunityCardView(community: community)
            }
            
            if builder.communities.isEmpty {
                VStack {
                    Image(systemName: "building.2.crop.circle")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("No communities available")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("Check back soon for new communities")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            }
        }
        .padding()
    }
}

// MARK: - Incentives Tab
struct IncentivesTabView: View {
    let builder: Builder
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let incentives = builder.currentIncentives, !incentives.isEmpty {
                ForEach(incentives, id: \.self) { incentive in
                    HStack {
                        Image(systemName: "tag.fill")
                            .foregroundColor(.orange)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(incentive)
                                .font(.body)
                                .fontWeight(.medium)
                            
                            Text("Contact builder for details")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
            } else {
                VStack {
                    Image(systemName: "tag.circle")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("No current incentives")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("Check back regularly for new offers")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            }
        }
        .padding()
    }
}

// MARK: - Community Card View
struct CommunityCardView: View {
    let community: CommunityDetails
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Community Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(community.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    HStack {
                        Image(systemName: "location")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("\(community.city), \(community.state) \(community.zipCode)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Status Badge
                Text(community.status.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(community.status == .activelySelling ? .green : .orange)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        (community.status == .activelySelling ? Color.green : Color.orange).opacity(0.1)
                    )
                    .cornerRadius(8)
            }
            
            // Price Range
            Text(community.priceRange?.formattedRange ?? "Price available upon request")
                .font(.subheadline)
                .foregroundColor(.blue)
                .fontWeight(.medium)
            
            // Home Types
            if !community.homeTypes.isEmpty {
                HStack {
                    Image(systemName: "house")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(community.homeTypes.map(\.displayName).joined(separator: ", "))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Amenities
            if !community.amenities.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(community.amenities.prefix(5), id: \.self) { amenity in
                            Text(amenity)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 1)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Stat View
struct StatView: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(.blue)
                
                Text(value)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    NavigationView {
        BuilderDetailView(builder: MockData.sampleBuilders[0])
    }
}