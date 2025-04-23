//
//  AsyncFlowEnvironment.swift
//  AsyncFlow
//
//  Created by Robert Clegg on 2025/03/23.
//

import Foundation

/// A struct representing the configuration for the environment, including URLs for both development and production.
public struct APIEnvironment: Sendable {
    let baseURL: String
    let authToken: String

    /// Initializes the environment configuration with URLs for both environments.
    /// - Parameters:
    ///   - baseURL: The base URL for the development environment.
    ///   - prodUrl: The base URL for the production environment.
    public init(baseURL: String,
                authToken: String = "") {
        self.baseURL = baseURL
        self.authToken = authToken
    }
}
