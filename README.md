# AsyncFlow

**AsyncFlow** is a Swift package designed to simplify and streamline async networking in Swift applications. It provides a clean and structured approach to handling asynchronous API calls with modern Swift concurrency.
![GitHub Actions](https://github.com/RJ-Clegg/AsyncFlow/actions/workflows/build.yml/badge.svg)

## Features
- **Lightweight & Efficient** – Built with Swift Concurrency (`async/await`).
- **Protocol-Oriented** – Easily extend and customize for different networking needs.
- **Error Handling** – Provides robust error handling for network requests.
- **Composable API** – Designed for reusability and modularity.

## Installation
### Swift Package Manager (SPM)
1. Open your Xcode project.
2. Go to `File > Add Packages...`
3. Enter the repository URL:
   ```
   https://github.com/RJ-Clegg/AsyncFlow
   ```
4. Choose a version and add the package to your project.

## Setup 

Where appropriate (AppDelegate etc) 

```swift
     let env = APIEnvironment(
            devUrl: "https://api-sandbox.company.com",
            prodUrl: "https://api.company.com",
            enviroment: .dev, 
            authToken: "<Token>"
        )

        AsyncFlow.setup(environment: env)
```
## Usage

### Defining an Endpoint
```swift
struct TransactionEndpoint: APIRequest {
   var path: String {
        switch self {
        case .settledTransactions(let accountUid, _):
            return "/api/v2/transactions"
        }
    }

    var queryItems: [URLQueryItem]? {
        switch self {
        case .settledTransactions(_, let dateRange):
            let minDateQueryItem = URLQueryItem(
                name: "minTransactionTimestamp",
                value: dateRange.minTransactionTimestamp
            )

            let maxDateQueryItem = URLQueryItem(
                name: "maxTransactionTimestamp",
                value: dateRange.maxTransactionTimestamp
            )

            return [minDateQueryItem, maxDateQueryItem]
        }
    }
}

```

### Making a Network Request
```swift
   func fetchTrasactions() async throws -> [Transaction] {
        let result: TransactionsListResponse = try await apiClient.data(for: TransactionEndpoint.settledTransactions(12345))
        return result.transactions
    }
```

## Requirements
- iOS 17.0+ / macOS 14.0+
- Swift 5.5+

## Contributions
Contributions are welcome! Feel free to open issues and submit pull requests.

## Author
Created by [Robert J Clegg](https://github.com/RJ-Clegg).
