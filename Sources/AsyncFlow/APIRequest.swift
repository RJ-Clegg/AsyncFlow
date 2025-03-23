//
//  APIRequest.swift
//  AsyncFlow
//
//  Created by Robert Clegg on 2025/03/23.
//

import Foundation

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
    case head = "HEAD"
    case options = "OPTIONS"
    case trace = "TRACE"
    case connect = "CONNECT"
}

/// A protocol representing an API request that can be used to configure and execute HTTP requests.
public protocol APIRequest {

    /// The relative path of the API request (e.g., "/users/{id}").
    var path: String { get }

    /// The full URL for the API request, combining the base URL and the path.
    var url: URL { get }

    /// A dictionary of headers to be included in the request, typically used for authentication, content type, etc.
    var headers: [String: String] { get }

    /// Optional query items to be added to the URL for GET requests, such as search parameters.
    var queryItems: [URLQueryItem]? { get }

    /// The HTTP method (GET, POST, PUT, DELETE, etc.) to be used for the request.
    var httpMethod: HTTPMethod { get }

    /// The body of the request, typically used for POST and PUT requests containing JSON or other data.
    var body: Data? { get }

    /// A boolean value indicating whether or not to ignore the cache policy for the request.
    var ignoresCachePolicy: Bool { get }

    /// The strategy to use for decoding keys. Defaults to `.useDefaultKeys`.
    var keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy { get }
}

public extension APIRequest {

    var url: URL {
        let url = AsyncFlow.shared.environment.baseURL
        var components = URLComponents(string: url)!
        components.scheme = "https"
        components.path =  path
        components.queryItems = queryItems

        guard let url = components.url else {
            preconditionFailure("Invalid URL components: \(components)")
        }

        return url
    }
    /// The default HTTP method for the request, which is GET. Can be overridden by specific requests.
    var httpMethod: HTTPMethod { .get }

    /// The default value for ignoresCachePolicy, which is false.
    var ignoresCachePolicy: Bool { false }

    /// The default body of the request, which is nil.
    var body: Data? { nil }

    /// The default query items for the request, which is an empty array.
    var queryItems: [URLQueryItem]? { [] }

    /// The default headers for the request, setting `Content-Type` and `Accept` to `"application/json"`.
    var headers: [String: String] {
        var headers:[String:String] = [:]
        headers["Authorization"] = AsyncFlow.shared.environment.authToken
        headers["Content-Type"] = "application/json"
        headers["Accept"] = "application/json"
        return headers
    }

    var keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy {
        .useDefaultKeys
    }
}
