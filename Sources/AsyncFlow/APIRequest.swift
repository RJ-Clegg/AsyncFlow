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

    /// A dictionary of headers to be included in the request, typically used for authentication, content type, etc.
    var headers: [String: String] { get }

    /// Optional query items to be added to the URL for GET requests, such as search parameters.
    var queryItems: [URLQueryItem]? { get }

    /// The HTTP method (GET, POST, PUT, DELETE, etc.) to be used for the request.
    var httpMethod: HTTPMethod { get }

    /// The body of the request, typically used for POST and PUT requests containing JSON or other data.
    var body: Data? { get }

    /// The strategy to use for decoding keys. Defaults to `.useDefaultKeys`.
    var keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy { get }
}

public extension APIRequest {
    /// The default HTTP method for the request, which is GET. Can be overridden by specific requests.
    var httpMethod: HTTPMethod { .get }

    /// The default body of the request, which is nil.
    var body: Data? { nil }

    /// The default query items for the request, which is nil.
    var queryItems: [URLQueryItem]? { nil }

    /// The default headers for the request, which are request-specific only.
    var headers: [String: String] { [:] }

    var keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy {
        .useDefaultKeys
    }
}
