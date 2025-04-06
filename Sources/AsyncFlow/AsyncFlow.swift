import Foundation

/// A protocol that defines the requirements for an AsyncFlow, which performs asynchronous network operations.
public protocol AsyncFlowProtocol {

    /// Loads data from the network asynchronously and decodes it into a model.
    /// - Parameter apiRequest: The API request to fetch data.
    /// - Returns: A decoded model object of type `Model`.
    /// - Throws: An error if the network request fails or the data cannot be decoded.
    func data<Model: Decodable>(for apiRequest: APIRequest) async throws -> Model
}

/// A singleton class that handles network requests and manages environment configurations.
public struct AsyncFlow: AsyncFlowProtocol, Sendable {
    private(set) var environment: APIEnvironment  // The environment configuration for the network session.
    private var session: NetworkSession       // The network session used for making requests.
    private static var isLoggingEnabled = false

    /// A private static variable holding the singleton instance.
    nonisolated(unsafe) private static var _intenalShared: AsyncFlow?

    /// The shared instance of `AsyncFlow` that can be used globally.
    public static var shared: AsyncFlow {
        if _intenalShared == nil {
            debugPrint("You did not explicitly set the environment, so we will default to DEV")
            _intenalShared = AsyncFlow(environment: APIEnvironment())
        }
        return _intenalShared!
    }

    /// Private initializer to create the `AsyncFlow` instance with an environment and an optional URLSession.
    /// - Parameters:
    ///   - environment: The environment configuration (e.g., dev, prod).
    ///   - session: The network session for making requests (default is `URLSession`).
    private init(environment: APIEnvironment,
                 session: NetworkSession = URLSession(configuration: .default)) {
        self.environment = environment
        self.session = session
    }

    /// Sets up the singleton instance of `AsyncFlow` with a specified environment and network session.
    /// - Parameters:
    ///   - environment: The environment configuration to set.
    ///   - session: The network session to use for requests (default is `URLSession`).
    public static func setup(environment: APIEnvironment,
                             session: NetworkSession = URLSession(configuration: .default)) {
        _intenalShared = AsyncFlow(environment: environment, session: session)
    }
}

public extension AsyncFlow {

    /// Loads data from a network request asynchronously and decodes it into a model.
    /// - Parameter apiRequest: The `APIRequest` that defines the URL and parameters for the network request.
    /// - Returns: A decoded model object of type `Model`.
    /// - Throws: An error if the network request fails or the data cannot be decoded.
    func data<Model: Decodable>(for apiRequest: APIRequest) async throws -> Model {
        let request = request(for: apiRequest)
        let (data, urlResponse) = try await session.data(for: request)

        guard let httpResponse = urlResponse as? HTTPURLResponse else {
            throw APIError.invalidResponseType
        }

        guard (200 ..< 300).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse(statusCode: httpResponse.statusCode)
        }

        return try decodeResultsIfPossible(
            data,
            keyDecodingStrategy: apiRequest.keyDecodingStrategy
        )
    }

    /// Enables or disables logging of the JSON response for debugging purposes.
    /// - Parameter loggingEnabled: Pass `true` to enable logging, or `false` to disable it.
    static func set(loggingEnabled: Bool) {
        isLoggingEnabled = loggingEnabled
    }
}

private extension AsyncFlow {
    private func request(for apiRequest: APIRequest) -> URLRequest {
        let request: URLRequest

        if apiRequest.body != nil {
            request = buildHttpBodyRequest(for: apiRequest)
        } else {
            request = urlRequestWithHeaders(for: apiRequest)
        }

        return request
    }

    private func buildHttpBodyRequest(for apiRequest: APIRequest) -> URLRequest {
        var request = urlRequestWithHeaders(for: apiRequest)
        request.httpBody = apiRequest.body
        request.httpMethod = apiRequest.httpMethod.rawValue
        return request
    }

    private func urlRequestWithHeaders(for endpoint: APIRequest) -> URLRequest {
        var request = URLRequest(url: endpoint.url)
        request.httpMethod = endpoint.httpMethod.rawValue
        endpoint.headers.forEach({
            request.setValue($0.value, forHTTPHeaderField: $0.key)
        })
        return request
    }

    private func decodeResultsIfPossible<Model: Decodable>(_ data: Data, keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys) throws -> Model {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = keyDecodingStrategy
        AsyncFlow.logResponseIfNeeded(data)

        do {
            return try decoder.decode(Model.self, from: data)
        } catch {
            throw APIError.failedParsing(localizedDescription: "\(error)")
        }
    }

    private static func logResponseIfNeeded(_ data: Data) {
        guard isLoggingEnabled else { return }

        if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
           let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
           let prettyString = String(data: prettyData, encoding: .utf8) {
            debugPrint("JSON Response:\n\(prettyString)")
        }
    }
}
