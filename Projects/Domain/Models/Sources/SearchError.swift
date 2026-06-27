import Foundation

// MARK: - SearchError

public enum SearchError: Error, Equatable, Sendable {
    case network
    case rateLimited
    case decoding
    case empty
    case unknown
}
