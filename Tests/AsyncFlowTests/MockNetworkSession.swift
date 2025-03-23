//
//  MockNetworkSession.swift
//  AsyncFlow
//
//  Created by Robert Clegg on 2025/03/23.
//

import Foundation
import AsyncFlow

// MARK: - Mock NetworkSession
final class MockNetworkSession: NetworkSession, @unchecked Sendable {
    var data: Data?
    var response: URLResponse?
    var error: Error?

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        if let error = error { throw error }
        guard let data = data, let response = response else { throw APIError.invalidResponseType }
        return (data, response)
    }
}
