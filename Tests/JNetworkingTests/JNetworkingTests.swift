
@testable import JNetworking
import XCTest

final class JNetworkingTests: XCTestCase {
    
    func testEncodedBody() {
        let request = JNBodyRequest(url: URL.test, body: TestObject())
        let urlRequest = request.asURLRequest
        
        let data = try? XCTUnwrap(urlRequest.httpBody)
        let obj = try? JSONDecoder().decode(TestObject.self, from: data!)
        XCTAssertEqual(obj, TestObject())
    }
    
    func testSetJSONAsContentTypeHeader() {
        let request = JNBodyRequest(url: URL.test, body: TestObject())
        let urlRequest = request.asURLRequest
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField: "Content-Type"), "application/json")
    }
    
    func testSetsTheAllHTTPHeaderFields() {
        let request = JNBodyRequest(
            url: URL.test,
            body: TestObject(),
            headers: ["Cookie": "this-is-my-cookie=josue;"]
        )

        let urlRequest = request.asURLRequest
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField: "Cookie"), "this-is-my-cookie=josue;")
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField: "Content-Type"), "application/json")
    }
    
    func testUsesTheKeyEncodingStrategy() throws {
        let request = JNBodyRequest(
            url: URL.test,
            body: BodyNameObject(lastName: "LAST-NAME"),
            keyEncodingStrategy: .convertToSnakeCase
        )

        let urlRequest = request.asURLRequest
        let data = try XCTUnwrap(urlRequest.httpBody)
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data, options: []) as? [String: String])
        XCTAssertEqual(json["last_name"], "LAST-NAME")
    }
    
}

private struct BodyNameObject: Encodable {
    let lastName: String
}
