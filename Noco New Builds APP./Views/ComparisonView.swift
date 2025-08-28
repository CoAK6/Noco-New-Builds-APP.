//
//  ComparisonView.swift
//  Noco New Builds APP.
//
//  Created by mark leavitt on 8/27/25.
//

import SwiftUI

struct ComparisonView: View {
    @ObservedObject var comparisonService = ComparisonService.shared
    @Environment(\.dismiss) var dismiss
    
    private var comparison: BuilderComparison {
        BuilderComparison(builders: comparisonService.comparedBuilders)
    }
    
    var body: some View {
        NavigationView {
            Group {
                if comparisonService.comparedBuilders.isEmpty {
                    EmptyComparisonView()
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            // Builder Headers
                            BuilderHeadersView(builders: comparisonService.comparedBuilders)
                            
                            // Comparison Categories
                            ForEach(comparison.categories, id: \.rawValue) { category in
                                ComparisonCategoryView(
                                    category: category,
                                    builders: comparisonService.comparedBuilders
                                )
                            }
                            
                            Spacer(minLength: 100) // Space for floating action button
                        }
                    }
                }
            }
            .navigationTitle("Compare Builders")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Clear All") {
                        comparisonService.clearComparison()
                    }
                    .foregroundColor(.red)
                    .disabled(comparisonService.comparedBuilders.isEmpty)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            comparisonService.recordComparison()
        }
    }
}

// MARK: - Builder Headers View
struct BuilderHeadersView: View {
    let builders: [Builder]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 16) {
                ForEach(builders) { builder in
                    BuilderComparisonHeader(builder: builder)
                        .frame(width: 280)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 16)
        }
        .background(Color(.systemGray6))
    }
}

// MARK: - Builder Comparison Header
struct BuilderComparisonHeader: View {
    let builder: Builder
    @ObservedObject var comparisonService = ComparisonService.shared
    
    var body: some View {
        VStack(spacing: 12) {
            // Remove Button
            HStack {
                Spacer()
                Button(action: { 
                    comparisonService.removeFromComparison(builder)
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .background(Color.white)
                        .clipShape(Circle())
                }
            }
            
            // Builder Logo
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
            
            // Builder Name
            Text(builder.name)
                .font(.headline)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            // Price Range
            Text(builder.priceRange.formattedRange)
                .font(.subheadline)
                .foregroundColor(.blue)
                .fontWeight(.medium)
            
            // Rating
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.caption)
                
                Text(builder.formattedRating)
                    .font(.caption)
                    .fontWeight(.medium)
                
                Text("(\(builder.reviewCount))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Comparison Category View
struct ComparisonCategoryView: View {
    let category: ComparisonCategory
    let builders: [Builder]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Category Header
            HStack {
                Text(category.rawValue)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(Color(.systemGray5))
            
            // Comparison Rows
            ForEach(Array(category.getComparisonRows(for: builders).enumerated()), id: \.offset) { index, row in
                ComparisonRowView(row: row, isEven: index % 2 == 0)
            }
        }
    }
}

// MARK: - Comparison Row View
struct ComparisonRowView: View {
    let row: ComparisonRow
    let isEven: Bool
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .center, spacing: 0) {
                // Row Label
                Text(row.label)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .frame(width: 120, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.systemGray6))
                
                // Values
                ForEach(Array(row.values.enumerated()), id: \.offset) { index, value in
                    Text(value)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .frame(width: 280, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(isEven ? Color(.systemBackground) : Color(.systemGray6))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Empty Comparison View
struct EmptyComparisonView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "scale.3d")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            VStack(spacing: 8) {
                Text("No Builders to Compare")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Add builders from the directory to compare their features, pricing, and communities side-by-side.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Comparison Floating Button
struct ComparisonFloatingButton: View {
    @ObservedObject var comparisonService = ComparisonService.shared
    @State private var showingComparison = false
    
    var body: some View {
        if comparisonService.comparisonCount > 0 {
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    Button(action: { showingComparison = true }) {
                        HStack {
                            Image(systemName: "scale.3d")
                                .font(.headline)
                            
                            Text("Compare (\(comparisonService.comparisonCount))")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .cornerRadius(25)
                        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
            }
            .sheet(isPresented: $showingComparison) {
                ComparisonView()
            }
        }
    }
}

#Preview {
    ComparisonView()
}