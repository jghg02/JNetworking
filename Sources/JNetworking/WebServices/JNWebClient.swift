//
//  JNWebClient.swift
//  
//
//  Created by Josue Hernandez on 29-06-22.
//

import Foundation


/// This is the struct to implement the request
public struct JNWebClient <T, E> where T: Decodable, E: LocalizedError & Decodable & Equatable {
    
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
    public func request(apiModel: APIModelType, completion: @escaping JNWebServiceBlock<T, E>) {
        
        self.requestLoader.requestAPIClient(apiModel: apiModel) { data, response, error in
            if let error = error {
                completion(.failure(.failedRequest(error)))
            } else if let response = response as? HTTPURLResponse {
                handleResponse(response, with: data, completion: completion)
            } else {
                completion(.failure(.failedRequest(nil)))
            }
        }
    }
    
    private func handleResponse<T, E>(_ response: HTTPURLResponse, with data: Data?, completion: @escaping JNWebServiceBlock<T, E>) {
        if (200 ..< 300).contains(response.statusCode) {
            handleSuccess(data, headers: response.allHeaderFields, completion: completion)
        } else {
            handleFailure(data, statusCode: response.statusCode, completion: completion)
        }
    }
    
    private func handleSuccess<T, E>(_ data: Data?, headers: [AnyHashable: Any], completion: @escaping JNWebServiceBlock<T, E>) {
        if let object: T = parse(data) {
            completion(.success(JNResponse(headers: headers, value: object)))
        } else {
            completion(.failure(.responseTypeMismatch))
        }
    }
    
    private func handleFailure<T, E>(_ data: Data?, statusCode: Int, completion: @escaping JNWebServiceBlock<T, E>) {
        if let error: E = parse(data) {
            completion(.failure(.invalidRequest(error)))
        } else {
            completion(.failure(.invalidResponse(statusCode)))
        }
    }
    
    private func parse<T: Decodable>(_ data: Data?) -> T? {
        guard let data = data else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
    
}
