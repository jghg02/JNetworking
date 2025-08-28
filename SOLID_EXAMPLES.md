# JNetworking Usage Examples: SOLID Principles in Action

This file demonstrates the SOLID principles through concrete examples from the JNetworking codebase.

## Good Examples: Following SOLID Principles

### 1. Dependency Inversion Principle (DIP) ✅

```swift
// Excellent example of DIP - depending on abstractions

// 1. Define the abstraction
protocol RequestLoader {
    func requestAPIClient(request: URLRequest, completion: @escaping JNWebServiceResult)
}

// 2. Use dependency injection
public struct JNWebClient<T, E> where T: Decodable, E: LocalizedError & Decodable & Equatable {
    private let requestLoader: RequestLoader  // ✅ Depends on abstraction
    
    public init(requestLoader: RequestLoader = URLSession.shared) {
        self.requestLoader = requestLoader  // ✅ Injection point
    }
}

// 3. Production usage
let productionClient = JNWebClient<UserModel, APIError>()  // Uses URLSession.shared

// 4. Testing usage
let testClient = JNWebClient<UserModel, APIError>(requestLoader: FakeRequestLoader())
```

### 2. Open/Closed Principle (OCP) ✅

```swift
// Base class is closed for modification but open for extension

public class JNRequest {
    // ✅ Core functionality is stable
    var asURLRequest: URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        addToRequest(&request)  // ✅ Extension point
        return request
    }
    
    // ✅ Override point for extensions
    func addToRequest(_ request: inout URLRequest) {}
}

// ✅ Extension without modification
public class JNBodyRequest<T: Encodable>: JNRequest {
    override func addToRequest(_ request: inout URLRequest) {
        request.httpBody = try? JSONEncoder().encode(body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    }
}

// ✅ Could add more extensions without changing base class
public class JNMultipartRequest: JNRequest {
    override func addToRequest(_ request: inout URLRequest) {
        // Add multipart form data
        request.setValue("multipart/form-data", forHTTPHeaderField: "Content-Type")
    }
}
```

### 3. Single Responsibility Principle (SRP) ✅

```swift
// ✅ Good example: Single purpose data containers

public struct JNResponse<T> {
    public let headers: [AnyHashable: Any]
    public let value: T
}
// Purpose: Hold response data and headers - that's it!

public struct JNEmpty: Decodable, LocalizedError, Equatable {}
// Purpose: Represent empty/no data - single, clear purpose

public enum HTTPMethodType: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}
// Purpose: Define HTTP methods - focused responsibility
```

### 4. Liskov Substitution Principle (LSP) ✅

```swift
// ✅ Perfect substitutability example

func performRequest<T: Decodable>(_ request: JNRequest) -> URLRequest {
    return request.asURLRequest  // Works with base class
}

// All subclasses can be substituted without breaking functionality
let baseRequest = JNRequest(url: url)
let bodyRequest = JNBodyRequest(url: url, body: data)

// ✅ Both work the same way
let urlRequest1 = performRequest(baseRequest)
let urlRequest2 = performRequest(bodyRequest)  // Perfect substitution
```

## Problem Examples: SOLID Principle Violations

### 1. Single Responsibility Principle (SRP) ❌

```swift
// ❌ JNWebClient does too many things
public struct JNWebClient<T, E> {
    // Responsibility 1: Execute network requests
    public func request(request: JNRequest, completion: @escaping JNWebServiceBlock<T, E>) {
        self.requestLoader.requestAPIClient(request: request.asURLRequest) { /* ... */ }
    }
    
    // Responsibility 2: Handle HTTP responses
    private func handleResponse<T, E>(_ response: HTTPURLResponse, with data: Data?, completion: @escaping JNWebServiceBlock<T, E>) {
        if (200 ..< 300).contains(response.statusCode) {
            handleSuccess(data, headers: response.allHeaderFields, completion: completion)
        } else {
            handleFailure(data, statusCode: response.statusCode, completion: completion)
        }
    }
    
    // Responsibility 3: Parse JSON data
    private func parse<T: Decodable>(_ data: Data?) -> T? {
        guard let data = data else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
    
    // Responsibility 4: Handle success responses
    private func handleSuccess<T, E>(_ data: Data?, headers: [AnyHashable: Any], completion: @escaping JNWebServiceBlock<T, E>) {
        // ...
    }
    
    // Responsibility 5: Handle error responses
    private func handleFailure<T, E>(_ data: Data?, statusCode: Int, completion: @escaping JNWebServiceBlock<T, E>) {
        // ...
    }
}

// 🔧 Better approach: Split responsibilities
struct NetworkRequestExecutor {
    func execute(_ request: URLRequest) -> /* result */ {}
}

struct ResponseParser<T: Decodable> {
    func parse(_ data: Data) -> T? {}
}

struct ResponseHandler<T, E> {
    func handle(_ response: HTTPURLResponse, data: Data?) -> Result<T, E> {}
}
```

### 2. Open/Closed Principle (OCP) ❌

```swift
// ❌ JNJSONResponseDecoder is closed for extension
public class JNJSONResponseDecoder {
    public static func decodeFrom<T: Codable>(_ responseData: Data, returningModelType: T.Type, completion: JNJSONDecodeCompletion<T>) {
        do {
            let model = try JSONDecoder().decode(returningModelType, from: responseData)  // ❌ Hardcoded to JSON
            completion(model, nil)
        } catch {
            // ❌ Hardcoded error handling
        }
    }
}

// Problem: Cannot extend to support XML, Protobuf, or other formats without modifying this class

// 🔧 Better approach: Protocol-based decoder
protocol ResponseDecoder {
    func decode<T: Decodable>(_ data: Data, as type: T.Type) throws -> T
}

class JSONResponseDecoder: ResponseDecoder { /* JSON implementation */ }
class XMLResponseDecoder: ResponseDecoder { /* XML implementation */ }
class ProtobufResponseDecoder: ResponseDecoder { /* Protobuf implementation */ }
```

### 3. Interface Segregation Principle (ISP) ⚠️

```swift
// ⚠️ Potentially over-constrained generic types
public struct JNWebClient<T, E> where T: Decodable, E: LocalizedError & Decodable & Equatable {
    // Forces error types to be LocalizedError AND Decodable AND Equatable
    // What if I only need LocalizedError?
}

// 🔧 Better approach: Separate the concerns
protocol NetworkError: LocalizedError {}
protocol TestableNetworkError: NetworkError, Equatable {}
protocol SerializableNetworkError: NetworkError, Decodable {}

// Different clients for different needs
struct JNWebClient<T: Decodable, E: NetworkError> { /* Basic client */ }
struct TestableJNWebClient<T: Decodable, E: TestableNetworkError> { /* For testing */ }
struct PersistentJNWebClient<T: Decodable, E: SerializableNetworkError> { /* For caching */ }
```

## Real-World Usage Patterns

### Recommended Usage (Following SOLID)

```swift
// 1. Define your models following SRP
struct User: Decodable {
    let id: Int
    let name: String
    let email: String
}

struct APIError: LocalizedError, Decodable, Equatable {
    let message: String
    let code: Int
    
    var errorDescription: String? { message }
}

// 2. Create requests following OCP
let getUserRequest = JNRequest(
    url: URL(string: "https://api.example.com/users/1")!,
    method: .get
)

let createUserRequest = JNBodyRequest(
    url: URL(string: "https://api.example.com/users")!,
    method: .post,
    body: NewUserData(name: "John", email: "john@example.com")
)

// 3. Use dependency injection (DIP)
let client = JNWebClient<User, APIError>()  // Production
let testClient = JNWebClient<User, APIError>(requestLoader: mockLoader)  // Testing

// 4. Make requests
client.request(request: getUserRequest) { result in
    switch result {
    case .success(let response):
        print("User: \(response.value)")
    case .failure(let error):
        print("Error: \(error)")
    }
}
```

### What to Avoid

```swift
// ❌ Don't create monolithic request handlers
class MegaAPIHandler {
    func getUserData() { /* ... */ }
    func updateUser() { /* ... */ }
    func deleteUser() { /* ... */ }
    func parseJSON() { /* ... */ }
    func handleErrors() { /* ... */ }
    func validateResponse() { /* ... */ }
    func logRequests() { /* ... */ }
    // Too many responsibilities!
}

// ❌ Don't hardcode implementations
class APIClient {
    private let session = URLSession.shared  // Hardcoded dependency
    
    func request() {
        let decoder = JSONDecoder()  // Hardcoded decoder
        // Cannot be easily tested or extended
    }
}

// ❌ Don't violate LSP with inconsistent interfaces
class BaseRequest {
    func execute() -> String { return "base" }
}

class SpecialRequest: BaseRequest {
    override func execute() -> String {
        fatalError("This request cannot be executed!")  // Violates LSP
    }
}
```

## Key Takeaways

1. **SRP**: Keep classes focused on a single responsibility
2. **OCP**: Use protocols and inheritance to allow extension without modification
3. **LSP**: Ensure subclasses can substitute their parents seamlessly
4. **ISP**: Don't force clients to depend on interfaces they don't use
5. **DIP**: Depend on abstractions (protocols) not concrete implementations

The JNetworking library demonstrates good understanding of SOLID principles with room for improvement in some areas, particularly around breaking down large classes and improving extensibility.