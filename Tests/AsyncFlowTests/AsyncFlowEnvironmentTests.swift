//
//  AsyncFlowEnvironmentTests.swift
//  AsyncFlow
//
//  Created by Robert Clegg on 2025/03/23.
//

import XCTest
@testable import AsyncFlow

final class AsyncFlowEnvironmentTests: XCTestCase {

    // MARK: - Test Environment Enum
    func testAsyncFlowEnvironmentRawValues() {
        XCTAssertEqual(AsyncFlowEnvironment.dev.rawValue, "dev")
        XCTAssertEqual(AsyncFlowEnvironment.prod.rawValue, "prod")
    }

    // MARK: - Test APIEnvironment Initialization
    func testAPIEnvironmentInitialization() {
        let env = APIEnvironment(
            devUrl: "https://dev.example.com",
            prodUrl: "https://prod.example.com",
            enviroment: .prod,
            authToken: "test_token"
        )

        XCTAssertEqual(env.baseURL, "https://prod.example.com")
        XCTAssertEqual(env.authToken, "test_token")
    }

    // MARK: - Test Base URL Selection
    func testBaseURLForDevEnvironment() {
        let env = APIEnvironment(
            devUrl: "https://dev.example.com",
            prodUrl: "https://prod.example.com",
            enviroment: .dev
        )

        XCTAssertEqual(env.baseURL, "https://dev.example.com")
    }

    func testBaseURLForProdEnvironment() {
        let env = APIEnvironment(
            devUrl: "https://dev.example.com",
            prodUrl: "https://prod.example.com",
            enviroment: .prod
        )

        XCTAssertEqual(env.baseURL, "https://prod.example.com")
    }
}
