//
//  URLHelper.swift
//  
//
//  Created by Josue Hernandez on 01-07-22.
//

import Foundation

extension URL {
    static var test = Self(string: "https://example.com")!
}

extension URLRequest {
    static var test = Self(url: URL.test)
    static var testWithExtraProperties = Self(
        url: URL.test,
        cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
        timeoutInterval: 4.0
    )
}
