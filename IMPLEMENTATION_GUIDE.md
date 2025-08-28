# Implementation Guide: SOLID Principles Refactoring

## Before & After Code Examples

### 1. Fix Critical Import Issues

#### Current (Broken)
```swift
import Foundation
// ❌ Missing FoundationNetworking for URLRequest, URLSession, etc.
```

#### Fixed
```swift
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
```

### 2. Fix Generic Parameter Shadowing

#### Current (Warning in Swift 6)
```swift
public struct JNWebClient<T, E> {
    // ❌ Shadows outer T, E
    private func handleResponse<T, E>(_ response: HTTPURLResponse, completion: @escaping JNWebServiceBlock<T, E>) {
    }
}
```

#### Fixed
```swift
public struct JNWebClient<T, E> {
    // ✅ Clear, non-shadowing names
    private func handleResponse<Success, Failure>(_ response: HTTPURLResponse, completion: @escaping JNWebServiceBlock<Success, Failure>) {
    }
}
```

### 3. Extract Network Client (SRP + DIP)

#### Current (Violates SRP)
```swift
public struct JNWebClient<T, E> {
    private let requestLoader: RequestLoader
    
    public func request(request: URLRequest, completion: @escaping JNWebServiceBlock<T, E>) {
        // ❌ Mixing networking, parsing, error handling
        self.requestLoader.requestAPIClient(request: request) { data, response, error in
            if let error = error {
                completion(.failure(.failedRequest(error)))
            } else if let response = response as? HTTPURLResponse {
                handleResponse(response, with: data, completion: completion) // More mixed concerns
            }
        }
    }
}
```

#### Improved (Follows SRP + DIP)
```swift
// ✅ Single responsibility: Execute network requests
public protocol NetworkClient {
    func execute(_ request: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void)
}

// ✅ Single responsibility: Process responses  
public protocol ResponseProcessor {
    associatedtype Success: Decodable
    associatedtype Failure: LocalizedError & Decodable & Equatable
    
    func processResponse(data: Data?, response: URLResponse?, error: Error?) -> Result<JNResponse<Success>, JNNetworkError<Failure>>
}

// ✅ Dependency injection, focused responsibility
public struct JNWebClient<T: Decodable, E: LocalizedError & Decodable & Equatable> {
    private let networkClient: NetworkClient
    private let responseProcessor: any ResponseProcessor<Success = T, Failure = E>
    
    public init(networkClient: NetworkClient, responseProcessor: any ResponseProcessor<Success = T, Failure = E>) {
        self.networkClient = networkClient
        self.responseProcessor = responseProcessor
    }
    
    public func request(_ request: JNRequest, completion: @escaping JNWebServiceBlock<T, E>) {
        networkClient.execute(request.asURLRequest) { data, response, error in
            let result = responseProcessor.processResponse(data: data, response: response, error: error)
            completion(result)
        }
    }
}
```

### 4. Extract Response Processing (SRP + OCP)

#### Current (Closed for Extension)
```swift
// ❌ Private methods, can't be customized
private func handleResponse<T, E>(_ response: HTTPURLResponse, with data: Data?, completion: @escaping JNWebServiceBlock<T, E>) {
    if (200 ..< 300).contains(response.statusCode) {
        handleSuccess(data, headers: response.allHeaderFields, completion: completion)
    } else {
        handleFailure(data, statusCode: response.statusCode, completion: completion)
    }
}
```

#### Improved (Open for Extension)
```swift
// ✅ Strategy pattern - open for extension
public protocol ResponseProcessingStrategy {
    associatedtype Success: Decodable
    associatedtype Failure: LocalizedError & Decodable & Equatable
    
    func isSuccessStatusCode(_ statusCode: Int) -> Bool
    func processSuccess(data: Data?, headers: [AnyHashable: Any]) -> Result<Success, JNNetworkError<Failure>>
    func processFailure(data: Data?, statusCode: Int) -> JNNetworkError<Failure>
}

public struct DefaultResponseStrategy<T: Decodable, E: LocalizedError & Decodable & Equatable>: ResponseProcessingStrategy {
    private let decoder: DataDecoder
    
    public init(decoder: DataDecoder = JSONDecoder()) {
        self.decoder = decoder
    }
    
    public func isSuccessStatusCode(_ statusCode: Int) -> Bool {
        (200..<300).contains(statusCode)
    }
    
    public func processSuccess(data: Data?, headers: [AnyHashable: Any]) -> Result<T, JNNetworkError<E>> {
        guard let data = data else { return .failure(.responseTypeMismatch) }
        
        do {
            let object = try decoder.decode(T.self, from: data)
            return .success(JNResponse(headers: headers, value: object))
        } catch {
            return .failure(.responseTypeMismatch)
        }
    }
    
    public func processFailure(data: Data?, statusCode: Int) -> JNNetworkError<E> {
        guard let data = data else { return .invalidResponse(statusCode) }
        
        do {
            let error = try decoder.decode(E.self, from: data)
            return .invalidRequest(error)
        } catch {
            return .invalidResponse(statusCode)
        }
    }
}
```

### 5. Injectable Data Decoder (DIP)

#### Current (Hard Dependency)
```swift
// ❌ Hardcoded JSONDecoder
private func parse<T: Decodable>(_ data: Data?) -> T? {
    guard let data = data else { return nil }
    return try? JSONDecoder().decode(T.self, from: data) // Hard dependency
}
```

#### Improved (Dependency Injection)
```swift
// ✅ Protocol for flexible decoding
public protocol DataDecoder {
    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T
}

// ✅ Make JSONDecoder conform
extension JSONDecoder: DataDecoder {}

// ✅ Custom decoder example
public struct LoggingDecoder: DataDecoder {
    private let decoder: JSONDecoder
    private let logger: Logger
    
    public init(decoder: JSONDecoder = JSONDecoder(), logger: Logger) {
        self.decoder = decoder
        self.logger = logger
    }
    
    public func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        do {
            let result = try decoder.decode(type, from: data)
            logger.debug("Successfully decoded \(type)")
            return result
        } catch {
            logger.error("Failed to decode \(type): \(error)")
            throw error
        }
    }
}
```

### 6. Protocol-Based Design (OCP)

#### Current (Closed Struct)
```swift
// ❌ Struct - cannot extend via inheritance
public struct JNWebClient<T, E> {
    // Implementation
}
```

#### Improved (Protocol-Based)
```swift
// ✅ Protocol allows multiple implementations
public protocol WebClient {
    associatedtype Success: Decodable
    associatedtype Failure: LocalizedError & Decodable & Equatable
    
    func request(_ request: JNRequest) async throws -> JNResponse<Success>
    func request(_ request: JNRequest, completion: @escaping (Result<JNResponse<Success>, JNNetworkError<Failure>>) -> Void)
}

// ✅ Default implementation
public struct DefaultWebClient<T: Decodable, E: LocalizedError & Decodable & Equatable>: WebClient {
    public typealias Success = T
    public typealias Failure = E
    
    private let networkClient: NetworkClient
    private let responseStrategy: any ResponseProcessingStrategy<Success = T, Failure = E>
    
    public init(
        networkClient: NetworkClient = URLSessionNetworkClient(),
        responseStrategy: any ResponseProcessingStrategy<Success = T, Failure = E> = DefaultResponseStrategy<T, E>()
    ) {
        self.networkClient = networkClient
        self.responseStrategy = responseStrategy
    }
    
    // Implementation
}

// ✅ Easy to create specialized versions
public struct AuthenticatedWebClient<T: Decodable, E: LocalizedError & Decodable & Equatable>: WebClient {
    private let baseClient: any WebClient<Success = T, Failure = E>
    private let authenticator: Authenticator
    
    // Automatically adds authentication to all requests
}
```

### 7. Add Async/Await Support

#### New Modern API
```swift
public extension WebClient {
    func request(_ request: JNRequest) async throws -> JNResponse<Success> {
        try await withCheckedThrowingContinuation { continuation in
            self.request(request) { result in
                continuation.resume(with: result)
            }
        }
    }
}

// Usage
let client: any WebClient<User, APIError> = DefaultWebClient()
do {
    let response = try await client.request(JNRequest(url: userURL))
    print("User: \(response.value)")
} catch {
    print("Error: \(error)")
}
```

### 8. Interceptor Pattern

#### Add Cross-Cutting Concerns
```swift
public protocol RequestInterceptor {
    func intercept(_ request: inout URLRequest) async throws
}

public protocol ResponseInterceptor {
    func intercept(_ data: Data?, response: URLResponse?, error: Error?) async
}

// Example: Logging interceptor
public struct LoggingInterceptor: RequestInterceptor, ResponseInterceptor {
    private let logger: Logger
    
    public func intercept(_ request: inout URLRequest) async throws {
        logger.info("🚀 Request: \(request.httpMethod ?? "GET") \(request.url?.absoluteString ?? "")")
    }
    
    public func intercept(_ data: Data?, response: URLResponse?, error: Error?) async {
        if let error = error {
            logger.error("❌ Request failed: \(error)")
        } else if let httpResponse = response as? HTTPURLResponse {
            logger.info("✅ Response: \(httpResponse.statusCode)")
        }
    }
}
```

## Migration Strategy

### Step 1: Add New APIs Alongside Old Ones
```swift
// Keep old API working
public struct JNWebClient<T, E> {
    @available(*, deprecated, message: "Use DefaultWebClient instead")
    public init(requestLoader: RequestLoader = URLSession.shared) {
        // Bridge to new implementation
    }
}

// Add new API
public struct DefaultWebClient<T, E>: WebClient {
    // New implementation
}
```

### Step 2: Provide Migration Helpers
```swift
public extension JNWebClient {
    func migrated() -> DefaultWebClient<T, E> {
        return DefaultWebClient(
            networkClient: URLSessionNetworkClient(session: self.requestLoader as! URLSession),
            responseStrategy: DefaultResponseStrategy<T, E>()
        )
    }
}
```

This approach ensures backward compatibility while enabling gradual adoption of the improved architecture.