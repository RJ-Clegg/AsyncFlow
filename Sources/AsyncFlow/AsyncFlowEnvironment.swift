//
//  AsyncFlowEnvironment.swift
//  AsyncFlow
//
//  Created by Robert Clegg on 2025/03/23.
//

import Foundation

/// An enum representing the environment for network requests, which can be either development or production.
public enum AsyncFlowEnvironment: String, Sendable {
    /// Development environment, used for testing and development purposes.
    case dev
    /// Production environment, used for live and stable services.
    case prod
}

/// A struct representing the configuration for the environment, including URLs for both development and production.
public struct APIEnvironment: Sendable {
    private let devUrl: String   // The base URL for the development environment.
    private let prodUrl: String  // The base URL for the production environment.
    private let enviroment: AsyncFlowEnvironment  // The current environment (dev or prod).
    let authToken: String
    /// Initializes the environment configuration with URLs for both environments.
    /// - Parameters:
    ///   - devUrl: The base URL for the development environment.
    ///   - prodUrl: The base URL for the production environment.
    ///   - enviroment: The current environment configuration (default is `.dev`).
    public init(devUrl: String = "",
                prodUrl: String = "",
                enviroment: AsyncFlowEnvironment = .dev,
                authToken: String = "") {
        self.devUrl = devUrl
        self.prodUrl = prodUrl
        self.enviroment = enviroment
        self.authToken = authToken
    }
}

public extension APIEnvironment {

    /// A computed property that returns the base URL depending on the current environment.
    /// - Returns: The base URL corresponding to either development or production.
    var baseURL: String {
        enviroment == .dev ? devUrl : prodUrl
    }
}
