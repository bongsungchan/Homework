import XCTest
@testable import Persistence
import Models

final class PersistenceTests: XCTestCase {

    private var sut: RecentSearchClient!
    private var defaults: UserDefaults!

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: "com.kurly.githubsearch.tests.\(UUID().uuidString)")!
        sut = .live(defaults: defaults)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: defaults.description)
        sut = nil
        defaults = nil
        super.tearDown()
    }

    func test_load_초기상태_빈배열() async throws {
        let result = try await sut.load()
        XCTAssertTrue(result.isEmpty)
    }

    func test_save_단일키워드_저장후반환() async throws {
        let result = try await sut.save("swift")
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].keyword, "swift")
    }

    func test_save_중복키워드_날짜갱신후상단이동() async throws {
        _ = try await sut.save("swift")
        _ = try await sut.save("tca")
        let result = try await sut.save("swift")
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].keyword, "swift")
        XCTAssertEqual(result[1].keyword, "tca")
    }

    func test_save_최대10개초과시오래된항목제거() async throws {
        for i in 1...11 {
            _ = try await sut.save("keyword\(i)")
        }
        let result = try await sut.load()
        XCTAssertEqual(result.count, 10)
        XCTAssertFalse(result.map(\.keyword).contains("keyword1"))
    }

    func test_save_날짜내림차순정렬() async throws {
        _ = try await sut.save("a")
        _ = try await sut.save("b")
        _ = try await sut.save("c")
        let result = try await sut.load()
        XCTAssertEqual(result.map(\.keyword), ["c", "b", "a"])
    }

    func test_delete_특정항목삭제() async throws {
        let saved = try await sut.save("swift")
        let id = saved[0].id
        let result = try await sut.delete(id)
        XCTAssertTrue(result.isEmpty)
    }

    func test_delete_존재하지않는id_목록유지() async throws {
        _ = try await sut.save("swift")
        let result = try await sut.delete(UUID())
        XCTAssertEqual(result.count, 1)
    }

    func test_deleteAll_전체삭제후빈배열() async throws {
        _ = try await sut.save("swift")
        _ = try await sut.save("tca")
        try await sut.deleteAll()
        let result = try await sut.load()
        XCTAssertTrue(result.isEmpty)
    }

    func test_영속성_재생성후데이터유지() async throws {
        _ = try await sut.save("swift")
        let newClient = RecentSearchClient.live(defaults: defaults)
        let result = try await newClient.load()
        XCTAssertEqual(result.map(\.keyword), ["swift"])
    }
}
