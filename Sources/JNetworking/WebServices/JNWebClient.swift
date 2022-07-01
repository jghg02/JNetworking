//
//  JNWebClient.swift
//  
//
//  Created by Josue Hernandez on 29-06-22.
//

import Foundation


/// This is the struct to implement the request
public struct JNWebClient {
    
    /// client a session
    private let requestLoader: RequestLoader
    
    
    /// Init method to inject any implementation of the RequestLoader protocol
    /// - Parameter requestLoader: This is the conforming RequestLoader protocol cobject as the default parameter will instantiate an URLSession
    public init(requestLoader: RequestLoader = URLSession.shared) {
        self.requestLoader = requestLoader
    }
    
    /// Performs a API request which is called by any service request class.
    /// It also performs an additional task of validating the auth token and refreshing if necessary
    ///
    /// - Parameters:
    ///   - apiModel: APIModelType which contains the info about api endpath, header & http method type.
    ///   - completion: Request completion handler.
    /// - Returns: Returns a URLSessionDataTask instance.
    public func request(apiModel: APIModelType, completion: @escaping JNWebServiceCompletionBlock) -> URLSessionDataTask? {
        return self.requestLoader.requestAPIClient(apiModel: apiModel, completion: completion)
    }
    
}
