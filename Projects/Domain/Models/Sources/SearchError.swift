import Foundation

// MARK: - SearchError

public enum SearchError: Error, Equatable, Sendable {
    case network
    case rateLimited
    case decoding
    case empty
    case unknown
}

// MARK: - User-Facing Message

extension SearchError {
    public var userFacingMessage: String {
        switch self {
        case .network:
            return "인터넷 연결을 확인해 주세요."
        case .rateLimited:
            return "요청이 많아요. 잠시 후 다시 시도해 주세요."
        case .empty:
            return "검색 결과가 없어요."
        case .decoding, .unknown:
            return "오류가 발생했어요. 다시 시도해 주세요."
        }
    }
}
