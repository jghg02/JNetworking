//
//  FakeRequestLoader.swift.swift
//  
//
//  Created by Josue Hernandez on 01-07-22.
//

import Foundation
import JNetworking

class FakeRequestLoader {
    
    private (set) var lastURL: URL?
    var nextData: Data?
    var nextResponse: URLResponse?
    var nextError: URLError?
    
    func requestAPIClient(apiModel: APIModelType, completion: @escaping JNWebServiceCompletionBlock) {
        URLSession.shared.dataTask(with: URL.test)
    }
    
}
