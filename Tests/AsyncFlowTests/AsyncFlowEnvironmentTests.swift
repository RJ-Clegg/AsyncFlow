//
//  AsyncFlowEnvironmentTests.swift
//  AsyncFlow
//
//  Created by Robert Clegg on 2025/03/23.
//
import Testing
@testable import AsyncFlow

struct AsyncFlowEnvironmentTests {

    @Test("AsyncFlow Enviroment Setup")
    func aPIEnvironmentInitialization() {
        let expectedURL = "https://dev.example.com"
        let token = "sdgfsfdgsdg54w6453tyhdfgfds"

        let env = APIEnvironment(
            baseURL: "https://dev.example.com",
            authToken: token
        )

        #expect(env.baseURL == expectedURL)
        #expect(env.authToken == token)
    }
}
