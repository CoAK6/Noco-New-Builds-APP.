//
//  APIService.swift
//  Noco New Builds APP.
//
//  Created by mark leavitt on 8/27/25.
//

import Foundation
import Combine

// MARK: - API Configuration
struct APIConfig {
    static let baseURL = URL(string: "https://your-vercel-app.vercel.app")! // Replace with your actual URL
    static let timeout: TimeInterval = 30.0
}

// MARK: - API Endpoints
enum APIEndpoint {
    case builders
    case builderDetail(id: String)
    case incentives
    case sendLead
    case userProfile(id: String)
    case saveBuilder(userId: String, builderId: String)
    case unsaveBuilder(userId: String, builderId: String)
    case saveComparison(userId: String)
    
    var path: String {
        switch self {
        case .builders:
            return "/api/builders"
        case .builderDetail(let id):
            return "/api/builders/\(id)"
        case .incentives:
            return "/api/incentives"
        case .sendLead:
            return "/api/send-lead"
        case .userProfile(let id):
            return "/api/users/\(id)"
        case .saveBuilder(let userId, let builderId):
            return "/api/users/\(userId)/saved-builders/\(builderId)"
        case .unsaveBuilder(let userId, let builderId):
            return "/api/users/\(userId)/saved-builders/\(builderId)"
        case .saveComparison(let userId):
            return "/api/users/\(userId)/comparisons"
        }
    }
    
    var url: URL {
        return APIConfig.baseURL.appendingPathComponent(path)
    }
    
    var method: HTTPMethod {
        switch self {
        case .builders, .builderDetail, .incentives, .userProfile:
            return .GET
        case .sendLead, .saveBuilder, .saveComparison:
            return .POST
        case .unsaveBuilder:
            return .DELETE
        }
    }
}

enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

// MARK: - API Error Types
enum APIError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case networkError(Error)
    case serverError(Int, String?)
    case unauthorized
    case rateLimited
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError(let error):
            return "Failed to decode data: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .serverError(let code, let message):
            return "Server error (\(code)): \(message ?? "Unknown error")"
        case .unauthorized:
            return "Unauthorized access"
        case .rateLimited:
            return "Too many requests. Please try again later."
        }
    }
}

// MARK: - API Response Types
struct APIResponse<T: Codable>: Codable {
    let data: T
    let message: String?
    let timestamp: Date
}

struct PaginatedResponse<T: Codable>: Codable {
    let data: [T]
    let pagination: PaginationInfo
    let message: String?
}

struct PaginationInfo: Codable {
    let currentPage: Int
    let totalPages: Int
    let totalItems: Int
    let itemsPerPage: Int
    let hasNextPage: Bool
    let hasPreviousPage: Bool
}

// MARK: - Main API Service
class APIService: ObservableObject {
    static let shared = APIService()
    
    private let session: URLSession
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = APIConfig.timeout
        config.timeoutIntervalForResource = APIConfig.timeout * 2
        self.session = URLSession(configuration: config)
    }
    
    // MARK: - Generic Request Method
    private func request<T: Codable>(
        endpoint: APIEndpoint,
        responseType: T.Type,
        body: Data? = nil,
        headers: [String: String] = [:]
    ) -> AnyPublisher<T, APIError> {
        
        var request = URLRequest(url: endpoint.url)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = body
        
        // Set default headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Add custom headers
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        return session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: T.self, decoder: JSONDecoder.iso8601)
            .mapError { error -> APIError in
                if error is DecodingError {
                    return .decodingError(error)
                } else {
                    return .networkError(error)
                }
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Builder API Methods
    func fetchBuilders() -> AnyPublisher<[Builder], APIError> {
        return request(endpoint: .builders, responseType: [Builder].self)
    }
    
    func fetchBuilderDetail(id: String) -> AnyPublisher<Builder, APIError> {
        return request(endpoint: .builderDetail(id: id), responseType: Builder.self)
    }
    
    // MARK: - Incentive API Methods
    func fetchIncentives() -> AnyPublisher<[Incentive], APIError> {
        return request(endpoint: .incentives, responseType: [Incentive].self)
    }
    
    // MARK: - User/Lead API Methods
    func sendLead(_ registrationData: UserRegistrationData) -> AnyPublisher<LeadResponse, APIError> {
        let body = try? JSONEncoder().encode(registrationData.toCRMLeadData())
        
        return request(
            endpoint: .sendLead,
            responseType: LeadResponse.self,
            body: body
        )
    }
    
    func saveBuilder(userId: String, builderId: String, notes: String? = nil) -> AnyPublisher<SavedBuilderResponse, APIError> {
        let requestBody = SaveBuilderRequest(builderId: builderId, notes: notes)
        let body = try? JSONEncoder().encode(requestBody)
        
        return request(
            endpoint: .saveBuilder(userId: userId, builderId: builderId),
            responseType: SavedBuilderResponse.self,
            body: body
        )
    }
    
    func unsaveBuilder(userId: String, builderId: String) -> AnyPublisher<EmptyResponse, APIError> {
        return request(
            endpoint: .unsaveBuilder(userId: userId, builderId: builderId),
            responseType: EmptyResponse.self
        )
    }
    
    func saveComparison(userId: String, builderIds: [String], criteria: String?, name: String?) -> AnyPublisher<ComparisonResponse, APIError> {
        let requestBody = SaveComparisonRequest(builderIds: builderIds, criteria: criteria, name: name)
        let body = try? JSONEncoder().encode(requestBody)
        
        return request(
            endpoint: .saveComparison(userId: userId),
            responseType: ComparisonResponse.self,
            body: body
        )
    }
}

// MARK: - Request/Response Models
struct LeadResponse: Codable {
    let success: Bool
    let message: String
    let leadId: String
    let timestamp: String
}

struct SaveBuilderRequest: Codable {
    let builderId: String
    let notes: String?
}

struct SavedBuilderResponse: Codable {
    let success: Bool
    let message: String
    let savedAt: String
}

struct SaveComparisonRequest: Codable {
    let builderIds: [String]
    let criteria: String?
    let name: String?
}

struct ComparisonResponse: Codable {
    let success: Bool
    let message: String
    let comparisonId: String
    let createdAt: String
}

struct EmptyResponse: Codable {
    let success: Bool
    let message: String
}

// MARK: - JSON Decoder Extension
extension JSONDecoder {
    static let iso8601: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
}

// MARK: - Network Reachability (Basic Implementation)
class NetworkMonitor: ObservableObject {
    @Published var isConnected = true
    @Published var connectionType: ConnectionType = .wifi
    
    enum ConnectionType {
        case wifi
        case cellular
        case none
    }
    
    // This is a simplified implementation
    // In a production app, you'd use Network framework or similar
    func startMonitoring() {
        // Implementation would go here
        print("Network monitoring started")
    }
    
    func stopMonitoring() {
        // Implementation would go here
        print("Network monitoring stopped")
    }
}

// MARK: - API Cache (Simple In-Memory Cache)
class APICache {
    static let shared = APICache()
    
    private var cache: [String: CacheEntry] = [:]
    private let cacheQueue = DispatchQueue(label: "api.cache.queue", attributes: .concurrent)
    
    private struct CacheEntry {
        let data: Data
        let timestamp: Date
        let expirationTime: TimeInterval
        
        var isExpired: Bool {
            Date().timeIntervalSince(timestamp) > expirationTime
        }
    }
    
    func set<T: Codable>(_ object: T, forKey key: String, expirationTime: TimeInterval = 300) {
        guard let data = try? JSONEncoder().encode(object) else { return }
        
        cacheQueue.async(flags: .barrier) {
            self.cache[key] = CacheEntry(
                data: data,
                timestamp: Date(),
                expirationTime: expirationTime
            )
        }
    }
    
    func get<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        return cacheQueue.sync {
            guard let entry = cache[key], !entry.isExpired else {
                cache.removeValue(forKey: key)
                return nil
            }
            
            return try? JSONDecoder().decode(type, from: entry.data)
        }
    }
    
    func removeAll() {
        cacheQueue.async(flags: .barrier) {
            self.cache.removeAll()
        }
    }
}

// MARK: - Development/Mock Data Support
extension APIService {
    // For development - returns mock data instead of making network calls
    var isUsingMockData: Bool {
        return APIConfig.baseURL.absoluteString.contains("localhost") || 
               ProcessInfo.processInfo.environment["USE_MOCK_DATA"] == "true"
    }
    
    func fetchMockBuilders() -> AnyPublisher<[Builder], APIError> {
        return Just(Builder.sampleBuilders)
            .setFailureType(to: APIError.self)
            .delay(for: .seconds(0.5), scheduler: DispatchQueue.main) // Simulate network delay
            .eraseToAnyPublisher()
    }
    
    func fetchMockIncentives() -> AnyPublisher<[Incentive], APIError> {
        return Just(Incentive.sampleIncentives)
            .setFailureType(to: APIError.self)
            .delay(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}