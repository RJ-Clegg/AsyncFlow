//
//  AsyncFlowEnvironmentTests.swift
//  AsyncFlow
//
//  Created by Robert Clegg on 2025/03/23.
//
import Testing
@testable import AsyncFlow

struct AsyncFlowEnvironmentTests {

    @Test("AsyncFlow Enviroment RawValues Values")
    func asyncFlowEnvironmentRawValues() {
        #expect(AsyncFlowEnvironment.dev.rawValue == "dev", "Rawvalue should be 'dev'")
        #expect(AsyncFlowEnvironment.prod.rawValue == "prod", "Rawvalue should be 'prod'")
    }

    @Test("AsyncFlow Enviroment Setup PROD")
    func aPIEnvironmentInitialization() {
        let expectedURL = "https://prod.example.com"
        let token = "sdgfsfdgsdg54w6453tyhdfgfds"

        let env = APIEnvironment(
            devUrl: "https://dev.example.com",
            prodUrl: expectedURL,
            enviroment: .prod,
            authToken: token
        )

        #expect(env.baseURL == expectedURL)
        #expect(env.authToken == token)
    }

    @Test("AsyncFlow Enviroment Setup DEV")
    func testBaseURLForDevEnvironment() {
        let expectedURL = "https://dev.example.com"

        let env = APIEnvironment(
            devUrl: expectedURL,
            prodUrl: "https://prod.example.com",
            enviroment: .dev
        )

        #expect(env.baseURL == expectedURL)
    }
}
