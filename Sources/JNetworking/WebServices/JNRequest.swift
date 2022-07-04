//
//  JNRequest.swift
//  
//
//  Created by Josue Hernandez on 02-07-22.
//

import Foundation

public class JNRequest {
    public typealias Headers = [String: String]

    public init(url: URL, method: HTTPMethodType = .get, headers: Headers = [:]) {
        self.url = url
        self.method = method
        self.headers = headers
    }

    // MARK: Internal

    var asURLRequest: URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        addToRequest(&request)
        return request
    }

    func addToRequest(_ request: inout URLRequest) {}

    // MARK: Private

    private let headers: Headers
    private let method: HTTPMethodType
    private let url: URL
}
