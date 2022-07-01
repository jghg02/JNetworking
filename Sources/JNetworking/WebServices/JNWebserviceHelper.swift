//
//  JNWebserviceHelper.swift
//  
//
//  Created by Josue German Hernandez Gonzalez on 20-07-21.
//

import Foundation

public enum NetworkError<T: LocalizedError>: LocalizedError {
    case failedRequest(URLError?)
    case invalidRequest(T)
    case invalidResponse(Int)
    case responseTypeMismatch
}

extension NetworkError: Equatable where T: Equatable {}

public typealias JNWebServiceCompletionBlock = (Result<Data, Error>) -> Void
public typealias JNWebServiceResult = (Data?, URLResponse?, URLError?) -> Void
public typealias JNWebServiceBlock<T, E> = (Result<JNResponse<T>, NetworkError<E>>) -> Void
    where T: Decodable, E: LocalizedError & Decodable & Equatable


/// Protocol
public protocol RequestLoader {
    func requestAPIClient(apiModel: APIModelType, completion: @escaping JNWebServiceResult)
}

/// Helper class to prepare request(adding headers & clubbing base URL) & perform API request.
extension URLSession: RequestLoader {
    
    /// Performs a API request which is called by any service request class.
    /// It also performs an additional task of validating the auth token and refreshing if necessary
    ///
    /// - Parameters:
    ///   - apiModel: APIModelType which contains the info about api endpath, header & http method type.
    ///   - completion: Request completion handler.
    public func requestAPIClient(apiModel: APIModelType, completion: @escaping JNWebServiceResult) {
        let escapedAddress = (apiModel.api.apiBasePath() + apiModel.api.apiEndPath()).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)

        var request = URLRequest(url: URL(string: escapedAddress!)!)
        request.httpMethod = apiModel.api.httpMthodType().rawValue
        request.allHTTPHeaderFields = JNWebserviceConfig().generateHeader()

        if let params = apiModel.parameters {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: params as Any, options: .prettyPrinted)
            } catch let error {
                print(error.localizedDescription)
            }
        }
        dataTask(with: request) { data, response, error in
            completion(data, response, error as? URLError)
        }
    }
    
}

