import XCTest
@testable import AsyncFlow

final class AsyncFlowTests: XCTestCase {

    private var asyncFlow: AsyncFlow!
    private var apiEnviroment: APIEnvironment!
    private var mockSession: MockNetworkSession!

    override func setUp() {
        super.setUp()
        mockSession = MockNetworkSession()
        apiEnviroment = APIEnvironment(
            devUrl: "https://www.dev.com",
            prodUrl: "https://www.prod.com",
            enviroment: .dev,
            authToken: "token"
        )

        AsyncFlow.setup(environment: apiEnviroment, session: mockSession)
        asyncFlow = .shared
    }

    override func tearDown() {
        asyncFlow = nil
        mockSession = nil
        super.tearDown()
    }

    // MARK: - Test Successful Request
    func testSuccessfulDataFetch() async throws {
        let mockData = """
        {
            "id": 1,
            "name": "Test User"
        }
        """.data(using: .utf8)!

        mockSession.data = mockData
        mockSession.response = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        struct User: Decodable {
            let id: Int
            let name: String
        }

        let user: User = try await asyncFlow.data(for: MockApiRequest())

        XCTAssertEqual(user.id, 1)
        XCTAssertEqual(user.name, "Test User")
    }

    func testSuccessfulDataFetchWithBodyInRequest() async throws {
        let mockData = """
        {
            "id": 1,
            "name": "Test User"
        }
        """.data(using: .utf8)!

        mockSession.data = mockData
        mockSession.response = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        struct User: Codable {
            let id: Int
            let name: String
        }

        var request = MockApiRequest()
        request.hasBody = true

        let user: User = try await asyncFlow.data(for: request)

        XCTAssertEqual(user.id, 1)
        XCTAssertEqual(user.name, "Test User")
    }

    // MARK: - Test Invalid HTTP Response
    func testInvalidResponseThrowsError() async {
        mockSession.response = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 500,
            httpVersion: nil,
            headerFields: nil
        )

        mockSession.data = """
        {
            "id": 1,
            "name": "Test User"
        }
        """.data(using: .utf8)!

        do {
            let _: String = try await asyncFlow.data(for: MockApiRequest())
            XCTFail("Expected error but got success")
        } catch let error as APIError {
            XCTAssertEqual(error, .invalidResponse(statusCode: 500))
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testNoResponseThrowsError() async {
        mockSession.response = URLResponse()
        mockSession.data = """
        {
            "id": 1,
            "name": "Test User"
        }
        """.data(using: .utf8)!

        do {
            let _: String = try await asyncFlow.data(for: MockApiRequest())
            XCTFail("Expected error but got success")
        } catch let error as APIError {
            XCTAssertEqual(error, .invalidResponseType)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    // MARK: - Test Decoding Failure
    func testDecodingFailureThrowsError() async {
        let invalidData = "invalid json".data(using: .utf8)!

        mockSession.data = invalidData
        mockSession.response = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        struct User: Decodable {
            let id: Int
            let name: String
        }

        do {
            let _: User = try await asyncFlow.data(for: MockApiRequest())
            XCTFail("Expected decoding error but got success")
        } catch let error as APIError {
            XCTAssertTrue(error.localizedDescription.contains("Failed to parse the response. Error:"))
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    // MARK: - Test Singleton Setup
    func testSharedInstanceDefaultSetup() {
        XCTAssertNotNil(AsyncFlow.shared)
    }
}
