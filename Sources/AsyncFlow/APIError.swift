//
//  APIError.swift
//  AsyncFlow
//
//  Created by Robert Clegg on 2025/03/23.
//

import Foundation

public enum APIError: Error, Equatable {
    /// Error when the response cannot be parsed successfully.
    /// - Parameter localizedDescription: A description of the parsing error.
    case failedParsing(localizedDescription: String)

    /// Error when there is a network failure (e.g., no internet connection, timeout).
    case networkFailure

    /// Error when the server responds with a status code that is not in the successful range (200-299).
    /// - Parameter statusCode: The status code returned by the server.
    case invalidResponse(statusCode: Int)

    /// Error when the response type is not as expected (e.g., not an `HTTPURLResponse`).
    case invalidResponseType

    /// Error when the user is unauthorized to perform the requested action.
    case unauthorized

    /// Custom error case that allows you to specify an arbitrary error message.
    /// - Parameter message: A custom error message.
    case custom(String)

    var localizedDescription: String {
        switch self {
        case .failedParsing(let localizedDescription):
            return "Failed to parse the response. Error: \(localizedDescription)"
        case .networkFailure:
            return "A network error occurred. Please try again."
        case .invalidResponse(let statusCode):
            return "Invalid server response. HTTP Status Code: \(statusCode)"
        case .invalidResponseType:
            return "Received an invalid response type, expected HTTPURLResponse."
        case .unauthorized:
            return "You are not authorized to perform this action."
        case .custom(let message):
            return message
        }
    }

    public static func == (lhs: APIError, rhs: APIError) -> Bool {
        switch (lhs, rhs) {
        case (.failedParsing(let lhsMessage), .failedParsing(let rhsMessage)):
            return lhsMessage == rhsMessage
        case (.networkFailure, .networkFailure):
            return true
        case (.invalidResponse(let lhsCode), .invalidResponse(let rhsCode)):
            return lhsCode == rhsCode
        case (.invalidResponseType, .invalidResponseType):
            return true
        case (.unauthorized, .unauthorized):
            return true
        case (.custom(let lhsMessage), .custom(let rhsMessage)):
            return lhsMessage == rhsMessage
        default:
            return false
        }
    }
}


