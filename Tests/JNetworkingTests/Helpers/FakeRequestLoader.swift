//
//  FakeRequestLoader.swift.swift
//  
//
//  Created by Josue Hernandez on 01-07-22.
//

import Foundation
import JNetworking

class FakeRequestLoader: RequestLoader {
    
    private(set) var lastLoadedRequest: URLRequest?
    
    var nextData: Data?
    var nextResponse: URLResponse?
    var nextError: URLError?
    
    func requestAPIClient(request: URLRequest, completion: @escaping JNWebServiceResult) {
        lastLoadedRequest = request
        completion(nextData, nextResponse, nextError)
    }
    
}
