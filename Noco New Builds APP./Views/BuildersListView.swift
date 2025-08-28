//
//  BuildersListView.swift
//  Noco New Builds APP.
//
//  Created by mark leavitt on 8/27/25.
//

import SwiftUI

struct BuildersListView: View {
    @StateObject private var viewModel = BuildersViewModel()
    @State private var searchText = ""
    @State private var selectedCategories: Set<BuilderCategory> = []
    @State private var selectedPriceRanges: Set<PriceRangeCategory> = []
    @State private var showingFilters = false
    @State private var sortOption: SortOption = .name
    
    private var filteredBuilders: [Builder] {
        viewModel.builders.filter { builder in
            // Search filter
            if !searchText.isEmpty {
                let searchLower = searchText.lowercased()
                let matchesName = builder.name.lowercased().contains(searchLower)
                let matchesCity = builder.communities.contains { community in
                    community.city.lowercased().contains(searchLower)
                }
                if !matchesName && !matchesCity {
                    return false
                }
            }
            
            // Category filter
            if !selectedCategories.isEmpty && !selectedCategories.contains(builder.category) {
                return false
            }
            
            // Price range filter
            if !selectedPriceRanges.isEmpty {
                let hasMatchingPriceRange = selectedPriceRanges.contains { priceCategory in
                    priceCategory.contains(priceRange: builder.priceRange)
                }
                if !hasMatchingPriceRange {
                    return false
                }
            }
            
            return true
        }.sorted { first, second in
            switch sortOption {
            case .name:
                return first.name < second.name
            case .priceRange:
                return first.priceRange.min < second.priceRange.min
            case .communities:
                return first.communities.count > second.communities.count
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                SearchBar(text: $searchText)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                
                // Filter and Sort Controls
                HStack {
                    // Filter Button
                    Button(action: { showingFilters = true }) {
                        HStack {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                            Text("Filter")
                            if !selectedCategories.isEmpty || !selectedPriceRanges.isEmpty {
                                Text("(\(selectedCategories.count + selectedPriceRanges.count))")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    Spacer()
                    
                    // Sort Menu
                    Menu {
                        Button("Name") { sortOption = .name }
                        Button("Price Range") { sortOption = .priceRange }
                        Button("Most Communities") { sortOption = .communities }
                    } label: {
                        HStack {
                            Text("Sort: \(sortOption.displayName)")
                            Image(systemName: "chevron.down")
                        }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
                
                // Results Count
                HStack {
                    Text("\(filteredBuilders.count) builders")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if viewModel.isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
                
                // Builders List
                if viewModel.isLoading && viewModel.builders.isEmpty {
                    VStack {
                        Spacer()
                        ProgressView("Loading builders...")
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                } else if filteredBuilders.isEmpty {
                    VStack {
                        Spacer()
                        Image(systemName: "building.2.crop.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No builders found")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding(.top)
                        
                        Text("Try adjusting your search or filters")
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        Button("Clear Filters") {
                            searchText = ""
                            selectedCategories.removeAll()
                            selectedPriceRanges.removeAll()
                        }
                        .foregroundColor(.blue)
                        .padding(.top)
                        
                        Spacer()
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredBuilders) { builder in
                                NavigationLink(destination: BuilderDetailView(builder: builder)) {
                                    BuilderCardView(builder: builder)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                    .refreshable {
                        await viewModel.loadBuilders()
                    }
                }
            }
            .navigationTitle("Builders")
            .navigationBarTitleDisplayMode(.large)
            .overlay(
                ComparisonFloatingButton(),
                alignment: .bottomTrailing
            )
            .sheet(isPresented: $showingFilters) {
                FilterView(
                    selectedCategories: $selectedCategories,
                    selectedPriceRanges: $selectedPriceRanges
                )
            }
            .onAppear {
                if viewModel.builders.isEmpty {
                    Task {
                        await viewModel.loadBuilders()
                    }
                }
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") { viewModel.clearError() }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
}

// MARK: - Search Bar
struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search builders or cities...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

// MARK: - Builder Card View
struct BuilderCardView: View {
    let builder: Builder
    @ObservedObject private var comparisonService = ComparisonService.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with logo and basic info
            HStack(alignment: .top, spacing: 12) {
                // Builder logo placeholder
                AsyncImage(url: URL(string: builder.logoUrl ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Text(builder.name.prefix(2).uppercased())
                                .font(.headline)
                                .foregroundColor(.white)
                        )
                }
                .frame(width: 60, height: 60)
                .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(builder.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(builder.category.displayName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(builder.priceRange.formattedRange)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                // Comparison Button
                Button(action: { 
                    comparisonService.toggleComparison(for: builder)
                }) {
                    Image(systemName: comparisonService.isInComparison(builder) ? "checkmark.circle.fill" : "plus.circle")
                        .font(.title3)
                        .foregroundColor(comparisonService.isInComparison(builder) ? .green : .blue)
                }
                .disabled(!comparisonService.canAddMore && !comparisonService.isInComparison(builder))
                .opacity((!comparisonService.canAddMore && !comparisonService.isInComparison(builder)) ? 0.5 : 1.0)
            }
            
            // Communities info
            if !builder.communities.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "building.2")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("\(builder.communities.count) communities")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        if builder.activeCommunities > 0 {
                            Text("\(builder.activeCommunities) active")
                                .font(.caption)
                                .foregroundColor(.green)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(4)
                        }
                    }
                    
                    // Sample cities
                    let cities = Array(Set(builder.communities.prefix(3).map(\.city))).sorted()
                    if !cities.isEmpty {
                        Text(cities.joined(separator: ", "))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
            }
            
            // Key features or incentives
            if let currentIncentives = builder.currentIncentives, !currentIncentives.isEmpty {
                HStack {
                    Image(systemName: "tag.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                    
                    Text("\(currentIncentives.count) current incentives")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .fontWeight(.medium)
                    
                    Spacer()
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Filter View
struct FilterView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedCategories: Set<BuilderCategory>
    @Binding var selectedPriceRanges: Set<PriceRangeCategory>
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Categories
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Builder Categories")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 8) {
                            ForEach(BuilderCategory.allCases, id: \.self) { category in
                                FilterChip(
                                    title: category.displayName,
                                    isSelected: selectedCategories.contains(category)
                                ) {
                                    if selectedCategories.contains(category) {
                                        selectedCategories.remove(category)
                                    } else {
                                        selectedCategories.insert(category)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Price Ranges
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Price Ranges")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 8) {
                            ForEach(PriceRangeCategory.allCases, id: \.self) { priceRange in
                                FilterChip(
                                    title: priceRange.displayName,
                                    isSelected: selectedPriceRanges.contains(priceRange)
                                ) {
                                    if selectedPriceRanges.contains(priceRange) {
                                        selectedPriceRanges.remove(priceRange)
                                    } else {
                                        selectedPriceRanges.insert(priceRange)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Filter Builders")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Clear All") {
                        selectedCategories.removeAll()
                        selectedPriceRanges.removeAll()
                    }
                    .foregroundColor(.red)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Filter Chip
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .blue)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color.blue.opacity(0.1))
                .cornerRadius(16)
        }
    }
}

// MARK: - Sort Options
enum SortOption: CaseIterable {
    case name
    case priceRange
    case communities
    
    var displayName: String {
        switch self {
        case .name: return "Name"
        case .priceRange: return "Price"
        case .communities: return "Communities"
        }
    }
}

// MARK: - Builders View Model
class BuildersViewModel: ObservableObject {
    @Published var builders: [Builder] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiService = APIService.shared
    
    @MainActor
    func loadBuilders() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Simulate API call - in real app would call apiService.getBuilders()
            try await Task.sleep(nanoseconds: 1_000_000_000)
            builders = MockData.sampleBuilders
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func clearError() {
        errorMessage = nil
    }
}

// MARK: - Mock Data
struct MockData {
    static let sampleBuilders: [Builder] = [Builder.sampleBuilder]
}

#Preview {
    BuildersListView()
}