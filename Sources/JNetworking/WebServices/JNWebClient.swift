//
//  JNWebClient.swift
//  
//
//  Created by Josue Hernandez on 29-06-22.
//

import Foundation


public struct JNWebClient {
    
    private let requestLoader: RequestLoader
    
    public init(requestLoader: RequestLoader = URLSession.shared) {
        self.requestLoader = requestLoader
    }
    
    public func request(apiModel: APIModelType, completion: @escaping JNWebServiceCompletionBlock) -> URLSessionDataTask? {
        return self.requestLoader.requestAPIClient(apiModel: apiModel, completion: completion)
    }
    
}
