//
//  NetworkSession.swift
//  AsyncFlow
//
//  Created by Robert Clegg on 2025/03/23.
//

import Foundation

/// Defines a NetworkSession protocol to allow easier testing
public protocol NetworkSession: Sendable {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

// Conform `URLSession` to `NetworkSession`
extension URLSession: NetworkSession {
    /// Default implementation of the `data(for:delegate:)` method that allows omitting the delegate.
    /// This implementation will pass `nil` for the delegate.
    /// - Parameters:
    ///   - request: The `URLRequest` object to send.
    /// - Returns: A tuple containing the fetched `Data` and `URLResponse`.
    /// - Throws: An error if the request fails.
    public func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await data(for: request, delegate: nil)
    }
}
