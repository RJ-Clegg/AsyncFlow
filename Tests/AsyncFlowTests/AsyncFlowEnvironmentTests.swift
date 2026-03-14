//
//  AsyncFlowEnvironmentTests.swift
//  AsyncFlow
//
//  Created by Robert Clegg on 2025/03/23.
//
import Foundation
import Testing
@testable import AsyncFlow

struct AsyncFlowEnvironmentTests {

    @Test("AsyncFlow Enviroment Setup")
    func aPIEnvironmentInitialization() {
        let expectedURL = URL(string: "https://dev.example.com")!

        let env = APIEnvironment(
            baseURL: expectedURL
        )

        #expect(env.baseURL == expectedURL)
    }
}
