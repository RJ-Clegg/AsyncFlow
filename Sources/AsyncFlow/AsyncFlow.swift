import Foundation

/// A protocol that defines the requirements for an AsyncFlow, which performs asynchronous network operations.
public protocol AsyncFlowProtocol {

    /// Loads data from the network asynchronously and decodes it into a model.
    /// - Parameter apiRequest: The API request to fetch data.
    /// - Returns: A decoded model object of type `Model`.
    /// - Throws: An error if the network request fails or the data cannot be decoded.
    func data<Model: Decodable>(for apiRequest: APIRequest) async throws -> Model
}

/// A lightweight client that performs asynchronous network operations.
public struct AsyncFlow: AsyncFlowProtocol, Sendable {
    public let config: AsyncFlowConfiguration
    private let session: any NetworkSession
    private let isLoggingEnabled: Bool

    /// Creates an `AsyncFlow` instance with runtime configuration and an optional URL session.
    /// - Parameters:
    ///   - configuration: The runtime configuration used to resolve environment and auth values.
    ///   - session: The network session for making requests (default is `URLSession`).
    ///   - loggingEnabled: Whether to pretty-print JSON responses for debugging.
    public init(configuration: AsyncFlowConfiguration,
                session: any NetworkSession = URLSession(configuration: .default),
                loggingEnabled: Bool = false) {
        self.config = configuration
        self.session = session
        self.isLoggingEnabled = loggingEnabled
    }
}

public extension AsyncFlow {

    /// Loads data from a network request asynchronously and decodes it into a model.
    /// - Parameter apiRequest: The `APIRequest` that defines the URL and parameters for the network request.
    /// - Returns: A decoded model object of type `Model`.
    /// - Throws: An error if the network request fails or the data cannot be decoded.
    func data<Model: Decodable>(for apiRequest: APIRequest) async throws -> Model {
        let configurationSnapshot = await config.snapshot()
        let request = request(for: apiRequest, configuration: configurationSnapshot)
        let (data, urlResponse) = try await session.data(for: request)

        guard let httpResponse = urlResponse as? HTTPURLResponse else {
            throw APIError.invalidResponseType
        }

        guard (200 ..< 300).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse(statusCode: httpResponse.statusCode)
        }

        logResponseIfNeeded(for: request, data: data)
        return try decodeResultsIfPossible(
            data,
            keyDecodingStrategy: apiRequest.keyDecodingStrategy
        )
    }
}

private extension AsyncFlow {
    private func request(for apiRequest: APIRequest,
                         configuration: AsyncFlowConfiguration.Snapshot) -> URLRequest {
        var request = URLRequest(
            url: buildURL(for: apiRequest, baseURL: configuration.environment.baseURL)
        )
        request.httpMethod = apiRequest.httpMethod.rawValue
        request.httpBody = apiRequest.body

        mergedHeaders(
            for: apiRequest,
            authorizationHeaderValue: configuration.authorizationHeaderValue
        ).forEach {
            request.setValue($0.value, forHTTPHeaderField: $0.key)
        }

        return request
    }

    private func buildURL(for apiRequest: APIRequest,
                          baseURL: URL) -> URL {
        guard var components = URLComponents(
            url: baseURL,
            resolvingAgainstBaseURL: false
        ) else {
            preconditionFailure("Invalid base URL: \(baseURL)")
        }

        components.path = normalizedPath(apiRequest.path)
        components.queryItems = apiRequest.queryItems

        guard let url = components.url else {
            preconditionFailure("Invalid URL components: \(components)")
        }

        return url
    }

    private func normalizedPath(_ path: String) -> String {
        guard path.hasPrefix("/") else {
            return "/" + path
        }

        return path
    }

    private func mergedHeaders(for apiRequest: APIRequest,
                               authorizationHeaderValue: String?) -> [String: String] {
        var headers = [
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]

        if let authorizationHeaderValue {
            headers["Authorization"] = authorizationHeaderValue
        }

        apiRequest.headers.forEach {
            headers[$0.key] = $0.value
        }

        return headers
    }

    private func decodeResultsIfPossible<Model: Decodable>(
        _ data: Data,
        keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys
    ) throws -> Model {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = keyDecodingStrategy

        do {
            return try decoder.decode(Model.self, from: data)
        } catch {
            throw APIError.failedParsing(localizedDescription: "\(error)")
        }
    }

    private func logResponseIfNeeded(for request: URLRequest, data: Data) {
        guard isLoggingEnabled else { return }

        if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
           let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
           let prettyString = String(data: prettyData, encoding: .utf8),
           let url = request.url {
            print("Request: \(url.absoluteString)  \n JSON Response:\n\(prettyString)")
        }
    }
}
