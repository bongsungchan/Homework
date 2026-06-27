import ComposableArchitecture
import Models
import XCTest

@testable import Networking

final class NetworkingTests: XCTestCase {

    func test_liveValue_isAccessible() {
        let client = RepositoryClient.liveValue
        XCTAssertNotNil(client.searchRepositories)
    }

    func test_dependencyValues_repositoryClient_returnsLive() {
        var values = DependencyValues._defaults
        XCTAssertNotNil(values.repositoryClient.searchRepositories)
    }

    func test_testValue_canBeOverridden() async throws {
        let stub = SearchResult(
            totalCount: 1,
            items: [
                GithubRepository(
                    id: 1,
                    name: "swift",
                    ownerLogin: "apple",
                    avatarURL: nil,
                    htmlURL: URL(string: "https://github.com/apple/swift")!,
                    description: nil,
                    stargazersCount: 999
                )
            ]
        )

        let result = try await withDependencies {
            $0.repositoryClient.searchRepositories = { _, _ in stub }
        } operation: {
            @Dependency(\.repositoryClient) var client
            return try await client.searchRepositories("swift", 1)
        }

        XCTAssertEqual(result.totalCount, 1)
        XCTAssertEqual(result.items.first?.name, "swift")
    }

    func test_http422_throwsNetworkError() async {
        URLProtocolStub.responseStatusCode = 422
        URLProtocolStub.responseData = Data()

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: config)
        let client = RepositoryClient.live(session: session)

        do {
            _ = try await client.searchRepositories("swift", 1)
            XCTFail("SearchError.network 가 던져져야 합니다.")
        } catch let error as SearchError {
            XCTAssertEqual(error, .network)
        } catch {
            XCTFail("예상치 못한 에러 타입: \(error)")
        }
    }

    func test_http403_throwsRateLimited() async {
        URLProtocolStub.responseStatusCode = 403
        URLProtocolStub.responseData = Data()

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: config)
        let client = RepositoryClient.live(session: session)

        do {
            _ = try await client.searchRepositories("swift", 1)
            XCTFail("SearchError.rateLimited 가 던져져야 합니다.")
        } catch let error as SearchError {
            XCTAssertEqual(error, .rateLimited)
        } catch {
            XCTFail("예상치 못한 에러 타입: \(error)")
        }
    }

    func test_emptyItems_throwsEmpty() async {
        let json = #"{"total_count":0,"incomplete_results":false,"items":[]}"#
        URLProtocolStub.responseStatusCode = 200
        URLProtocolStub.responseData = Data(json.utf8)

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: config)
        let client = RepositoryClient.live(session: session)

        do {
            _ = try await client.searchRepositories("zzz_no_match", 1)
            XCTFail("SearchError.empty 가 던져져야 합니다.")
        } catch let error as SearchError {
            XCTAssertEqual(error, .empty)
        } catch {
            XCTFail("예상치 못한 에러 타입: \(error)")
        }
    }

    func test_malformedJSON_throwsDecoding() async {
        URLProtocolStub.responseStatusCode = 200
        URLProtocolStub.responseData = Data("not-json".utf8)

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: config)
        let client = RepositoryClient.live(session: session)

        do {
            _ = try await client.searchRepositories("swift", 1)
            XCTFail("SearchError.decoding 이 던져져야 합니다.")
        } catch let error as SearchError {
            XCTAssertEqual(error, .decoding)
        } catch {
            XCTFail("예상치 못한 에러 타입: \(error)")
        }
    }
}

private final class URLProtocolStub: URLProtocol {
    static var responseStatusCode: Int = 200
    static var responseData: Data = Data()

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        let response = HTTPURLResponse(
            url: request.url!,
            statusCode: URLProtocolStub.responseStatusCode,
            httpVersion: "HTTP/1.1",
            headerFields: nil
        )!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: URLProtocolStub.responseData)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
