//
//  JNWebClientTest.swift
//  
//
//  Created by Josue Hernandez on 04-07-22.
//

@testable import JNetworking
import XCTest

class JNWebClientTest: XCTestCase {

    func testRequestLoadsTheRequest() {
        let requestLoader = FakeRequestLoader()
        let client = JNWebClient<JNEmpty, JNEmpty>(requestLoader: requestLoader)

        client.request(request: JNRequest(url: URL.test)) { _ in }

        XCTAssertEqual(requestLoader.lastLoadedRequest, URLRequest.test)
    }
    
    func testRequestWithURLRequest() {
        let requestLoader = FakeRequestLoader()
        let client = JNWebClient<JNEmpty, JNEmpty>(requestLoader: requestLoader)

        let expectedURLRequest = URLRequest.testWithExtraProperties
        client.request(request: expectedURLRequest) { _ in }

        XCTAssertEqual(requestLoader.lastLoadedRequest, expectedURLRequest)
    }
    
    func testRequestFailsWithANetworkError() {
        let requestLoader = FakeRequestLoader()
        let client = JNWebClient<JNEmpty, JNEmpty>(requestLoader: requestLoader)

        let networkError = URLError(.badURL)
        requestLoader.nextError = networkError

        client.request(request: JNRequest(url: URL.test)) { result in
            self.assertResultError(result, .failedRequest(URLError(.badURL)))
        }
    }
    
    func testRequest200RangeSucceedsWithParsedSuccessObject() throws {
        let requestLoader = FakeRequestLoader()
        let client = JNWebClient<TestObject, JNEmpty>(requestLoader: requestLoader)

        let exampleObject = TestObject()
        let data = try XCTUnwrap(JSONEncoder().encode(exampleObject))
        requestLoader.nextData = data

        let response = HTTPURLResponse(url: URL.test, statusCode: 200, httpVersion: nil, headerFields: ["HEADER": "value"])
        requestLoader.nextResponse = response

        client.request(request: JNRequest(url: URL.test)) { result in
            XCTAssertEqual(try? result.get().value, exampleObject)
            XCTAssertEqual(try? result.get().headers as? [String: String], ["HEADER": "value"])
        }
    }
    
    func testRequestNon200RangeFailsWithParsedErrorObject() throws {
        let requestLoader = FakeRequestLoader()
        let client = JNWebClient<JNEmpty, TestError>(requestLoader: requestLoader)

        let error = TestError(message: "Example message.....")
        let data = try XCTUnwrap(JSONEncoder().encode(error))
        requestLoader.nextData = data

        let response = HTTPURLResponse(url: URL.test, statusCode: 403, httpVersion: nil, headerFields: nil)
        requestLoader.nextResponse = response

        client.request(request: JNRequest(url: URL.test)) { result in
            self.assertResultError(result, .invalidRequest(error))
        }
    }
    

}

extension JNWebClientTest {
    
    func assertResultError<T, E>(
        _ result: Result<T, E>,
        _ expectedError: E,
        file: StaticString = #filePath,
        line: UInt = #line
    ) where E: Equatable {
        switch result {
        case .failure(let actualError):
            XCTAssertEqual(actualError, expectedError, file: file, line: line)
        case .success:
            XCTFail("Result did not fail", file: file, line: line)
        }
    }
    
}
