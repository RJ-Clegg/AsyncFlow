import Foundation
import Testing
@testable import AsyncFlow

struct AsyncFlowTests {
    private let asyncFlow: AsyncFlow
    private let apiEnviroment: APIEnvironment
    private let mockSession: MockNetworkSession

    init() async throws {
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

    @Test("Fetching data is successful")
    func successfulDataFetch() async throws {
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

        let user: User = try await asyncFlow.data(for: MockApiRequest())

        #expect(user.id == 1, "User ID should be 1")
        #expect(user.name == "Test User", "Username should be: Test User")
    }

    @Test("Fetch with body is successfull")
    func successfulDataFetchWithBodyInRequest() async throws {
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

        var request = MockApiRequest()
        request.hasBody = true

        let user: User = try await asyncFlow.data(for: request)

        #expect(user.id == 1, "User ID should be 1")
        #expect(user.name == "Test User", "Username should be: Test User")
    }

    @Test("Invalid HTTP responses")
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
            Issue.record("Expected error but got success")
        } catch let error as APIError {
            #expect(error == .invalidResponse(statusCode: 500))
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }

    @Test("Throws an error if no data")
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
            Issue.record("Expected error but got success")
        } catch let error as APIError {
            #expect(error == .invalidResponseType)
        } catch {
            Issue.record("Unexpected error type: \(error)")

        }
    }

    @Test("Decoding failure throws error")
    func testDecodingFailureThrowsError() async {
        let invalidData = "invalid json".data(using: .utf8)!

        mockSession.data = invalidData
        mockSession.response = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        do {
            let _: User = try await asyncFlow.data(for: MockApiRequest())
            Issue.record("Expected error but got success")
        } catch let error as APIError {
            #expect(error.localizedDescription.contains("Failed to parse the response. Error:"))
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }
}

private extension AsyncFlowTests {
    struct User: Decodable {
        let id: Int
        let name: String
    }
}
