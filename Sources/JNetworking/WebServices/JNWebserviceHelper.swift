//
//  JNWebserviceHelper.swift
//  
//
//  Created by Josue German Hernandez Gonzalez on 20-07-21.
//

import Foundation

public typealias JNWebServiceResult = (Data?, URLResponse?, URLError?) -> Void
public typealias JNWebServiceBlock<T, E> = (Result<JNResponse<T>, JNNetworkError<E>>) -> Void
    where T: Decodable, E: LocalizedError & Decodable & Equatable


/// Protocol
public protocol RequestLoader {
    func requestAPIClient(request: URLRequest, completion: @escaping JNWebServiceResult)
}

/// Helper class to prepare request(adding headers & clubbing base URL) & perform API request.
extension URLSession: RequestLoader {
    
    /// Performs a API request which is called by any service request class.
    /// It also performs an additional task of validating the auth token and refreshing if necessary
    ///
    /// - Parameters:
    ///   - request: URLRequest
    ///   - completion: Request completion handler.
    public func requestAPIClient(request: URLRequest, completion: @escaping JNWebServiceResult) {
        dataTask(with: request) { data, response, error in
            completion(data, response, error as? URLError)
        }
    }
    
}

