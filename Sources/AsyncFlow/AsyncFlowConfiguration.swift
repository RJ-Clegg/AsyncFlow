import Foundation

/// Stores runtime networking configuration that can be updated while the app is running.
public actor AsyncFlowConfiguration {
    struct Snapshot: Sendable {
        let environment: APIEnvironment
        let authorizationHeaderValue: String?
    }

    private var environment: APIEnvironment
    private var authorizationHeaderValue: String?

    public init(environment: APIEnvironment,
                authorizationHeaderValue: String? = nil) {
        self.environment = environment
        self.authorizationHeaderValue = authorizationHeaderValue
    }

    public func setEnvironment(_ environment: APIEnvironment) {
        self.environment = environment
    }

    public func setAuthorizationHeaderValue(_ authorizationHeaderValue: String?) {
        self.authorizationHeaderValue = authorizationHeaderValue
    }

    func snapshot() -> Snapshot {
        Snapshot(
            environment: environment,
            authorizationHeaderValue: authorizationHeaderValue
        )
    }
}
