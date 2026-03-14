import Foundation
import Testing
@testable import AsyncFlow

struct AsyncFlowTests {
    private let asyncFlow: AsyncFlow
    private let configuration: AsyncFlowConfiguration
    private let mockSession: MockNetworkSession

    init() async throws {
        mockSession = MockNetworkSession()
        configuration = AsyncFlowConfiguration(
            environment: APIEnvironment(baseURL: URL(string: "https://www.dev.com")!),
            authorizationHeaderValue: "token"
        )
        asyncFlow = AsyncFlow(
            configuration: configuration,
            session: mockSession,
            loggingEnabled: true
        )
    }

    @Test("Fetching data is successful")
    func successfulDataFetch() async throws {
        configureSuccessfulResponse()

        let user: User = try await asyncFlow.data(for: MockApiRequest())

        #expect(user.id == 1, "User ID should be 1")
        #expect(user.name == "Test User", "Username should be: Test User")
        #expect(mockSession.requests.count == 1)
        #expect(mockSession.requests[0].url?.absoluteString == "https://www.dev.com/mock/path")
        #expect(mockSession.requests[0].value(forHTTPHeaderField: "Authorization") == "token")
    }

    @Test("Fetch with body is successfull")
    func successfulDataFetchWithBodyInRequest() async throws {
        configureSuccessfulResponse()
        var request = MockApiRequest()
        request.hasBody = true

        let user: User = try await asyncFlow.data(for: request)

        #expect(user.id == 1, "User ID should be 1")
        #expect(user.name == "Test User", "Username should be: Test User")
        #expect(mockSession.requests[0].httpBody != nil)
    }

    @Test("Environment changes affect subsequent requests")
    func environmentChangesAffectSubsequentRequests() async throws {
        configureSuccessfulResponse()

        let _: User = try await asyncFlow.data(for: MockApiRequest())
        await configuration.setEnvironment(
            APIEnvironment(baseURL: URL(string: "https://www.prod.com")!)
        )
        let _: User = try await asyncFlow.data(for: MockApiRequest())

        #expect(mockSession.requests.count == 2)
        #expect(mockSession.requests[0].url?.absoluteString == "https://www.dev.com/mock/path")
        #expect(mockSession.requests[1].url?.absoluteString == "https://www.prod.com/mock/path")
    }

    @Test("Authorization changes independently of environment")
    func authorizationChangesIndependentlyOfEnvironment() async throws {
        configureSuccessfulResponse()

        let _: User = try await asyncFlow.data(for: MockApiRequest())
        await configuration.setAuthorizationHeaderValue("new-token")
        let _: User = try await asyncFlow.data(for: MockApiRequest())

        #expect(mockSession.requests.count == 2)
        #expect(mockSession.requests[0].url?.absoluteString == "https://www.dev.com/mock/path")
        #expect(mockSession.requests[1].url?.absoluteString == "https://www.dev.com/mock/path")
        #expect(mockSession.requests[0].value(forHTTPHeaderField: "Authorization") == "token")
        #expect(mockSession.requests[1].value(forHTTPHeaderField: "Authorization") == "new-token")
    }

    @Test("Request headers override defaults and configuration auth")
    func requestHeadersOverrideDefaultsAndConfigurationAuth() async throws {
        configureSuccessfulResponse()
        let request = MockApiRequest(
            customHeaders: [
                "Accept": "text/plain",
                "Authorization": "override-token",
                "Content-Type": "application/xml"
            ]
        )

        let _: User = try await asyncFlow.data(for: request)

        #expect(mockSession.requests.count == 1)
        #expect(mockSession.requests[0].value(forHTTPHeaderField: "Accept") == "text/plain")
        #expect(mockSession.requests[0].value(forHTTPHeaderField: "Authorization") == "override-token")
        #expect(mockSession.requests[0].value(forHTTPHeaderField: "Content-Type") == "application/xml")
    }

    @Test("Requests started before an environment change keep their original snapshot")
    func requestsStartedBeforeAnEnvironmentChangeKeepTheirOriginalSnapshot() async throws {
        let blockingSession = BlockingNetworkSession(
            data: makeUserData(),
            response: makeHTTPResponse(statusCode: 200)
        )
        let configuration = AsyncFlowConfiguration(
            environment: APIEnvironment(baseURL: URL(string: "https://www.dev.com")!),
            authorizationHeaderValue: "token"
        )
        let asyncFlow = AsyncFlow(configuration: configuration, session: blockingSession)

        let task = Task {
            try await asyncFlow.data(for: MockApiRequest()) as User
        }

        await blockingSession.waitForRequest()
        await configuration.setEnvironment(
            APIEnvironment(baseURL: URL(string: "https://www.prod.com")!)
        )
        await blockingSession.resume()

        let user = try await task.value
        let recordedRequest = await blockingSession.recordedRequest()

        #expect(user.id == 1)
        #expect(recordedRequest?.url?.absoluteString == "https://www.dev.com/mock/path")
    }

    @Test("Invalid HTTP responses")
    func testInvalidResponseThrowsError() async {
        mockSession.response = makeHTTPResponse(statusCode: 500)
        mockSession.data = makeUserData()

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
        mockSession.data = makeUserData()

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
        mockSession.data = "invalid json".data(using: .utf8)!
        mockSession.response = makeHTTPResponse(statusCode: 200)

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

    func configureSuccessfulResponse() {
        mockSession.data = makeUserData()
        mockSession.response = makeHTTPResponse(statusCode: 200)
    }

    func makeUserData() -> Data {
        """
        {
            "id": 1,
            "name": "Test User"
        }
        """.data(using: .utf8)!
    }

    func makeHTTPResponse(statusCode: Int) -> HTTPURLResponse {
        HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
    }
}

private actor BlockingNetworkSession: NetworkSession {
    private let data: Data
    private let response: URLResponse
    private var request: URLRequest?
    private var requestContinuation: CheckedContinuation<Void, Never>?
    private var resumeContinuation: CheckedContinuation<Void, Never>?

    init(data: Data, response: URLResponse) {
        self.data = data
        self.response = response
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        self.request = request
        requestContinuation?.resume()
        requestContinuation = nil

        await withCheckedContinuation { continuation in
            resumeContinuation = continuation
        }

        return (data, response)
    }

    func waitForRequest() async {
        guard request == nil else { return }

        await withCheckedContinuation { continuation in
            requestContinuation = continuation
        }
    }

    func recordedRequest() -> URLRequest? {
        request
    }

    func resume() {
        resumeContinuation?.resume()
        resumeContinuation = nil
    }
}
