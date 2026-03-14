//
//  File.swift
//  AsyncFlow
//
//  Created by Robert Clegg on 2025/03/23.
//

import Foundation
import AsyncFlow

fileprivate struct User: Codable {
    let id: Int
    let name: String
}

struct MockApiRequest: APIRequest {
    var hasBody = false
    var customHeaders: [String: String] = [:]
    var customQueryItems: [URLQueryItem]? = nil
    var customPath = "/mock/path"

    var path: String { customPath }

    var headers: [String: String] { customHeaders }

    var queryItems: [URLQueryItem]? { customQueryItems }

    var body: Data? {
        guard hasBody else { return nil }
        let user = User(id: 0, name: "")
        return try? JSONEncoder().encode(user)
    }
}
