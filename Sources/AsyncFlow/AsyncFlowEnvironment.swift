//
//  AsyncFlowEnvironment.swift
//  AsyncFlow
//
//  Created by Robert Clegg on 2025/03/23.
//

import Foundation

/// A struct representing the active backend environment.
public struct APIEnvironment: Sendable, Equatable {
    public let baseURL: URL

    /// Initializes the environment configuration.
    /// - Parameter baseURL: The base URL for the active environment.
    public init(baseURL: URL) {
        self.baseURL = baseURL
    }
}
