//
//  JNRequestTest.swift
//  
//
//  Created by Josue Hernandez on 04-07-22.
//

@testable import JNetworking
import XCTest

class JNRequestTest: XCTestCase {

    func testURLRequestSetsTheURL() {
        let getRequest = JNRequest(url: URL.test)
        XCTAssertEqual(getRequest.asURLRequest.url, URL.test)
    }
    
    func testURLRequestSetsHTTPMethodGET() {
        let getRequest = JNRequest(url: URL.test)
        XCTAssertEqual(getRequest.asURLRequest.httpMethod, "GET")
    }
    
    func testURLRequestSetsHTTPMethodDELETE() {
        let deleteRequest = JNRequest(url: URL.test, method: .delete)
        XCTAssertEqual(deleteRequest.asURLRequest.httpMethod, "DELETE")
    }
    
    func testURLRequestSetsHTTPMethodPATCH() {
        let patchRequest = JNRequest(url: URL.test, method: .patch)
        XCTAssertEqual(patchRequest.asURLRequest.httpMethod, "PATCH")
    }
     
    func testURLRequestSetsHTTPMethodPOST() {
        let postRequest = JNRequest(url: URL.test, method: .post)
        XCTAssertEqual(postRequest.asURLRequest.httpMethod, "POST")
    }

}
