//
//  JNWebserviceConfig.swift
//  
//
//  Created by Josue German Hernandez Gonzalez on 20-07-21.
//

import Foundation

/// HTTPMethodTypes
public enum HTTPMethodType: String {
    case get     = "GET"
    case post    = "POST"
    case put     = "PUT"
}

/// Protocol to which every API should confirm to.
protocol APIProtocol {
    func httpMthodType() -> HTTPMethodType
    func apiEndPath() -> String
    func apiBasePath() -> String
}

/// Request Model type that the APIRequestModel confirms to.
protocol APIModelType {
    var api: APIProtocol { get set }
    var parameters: [String: Any]? { get set }
}

/// Request Model that holds every api calls parameters, headers and other api details.
public struct APIRequestModel: APIModelType {
    var api: APIProtocol
    var parameters: [String: Any]?

    init(api: APIProtocol, parameters: [String: Any]? = nil) {
        self.api = api
        self.parameters = parameters
    }
}

/// Responsible for generating common headers for requests.
struct JNWebserviceConfig {
    /// Generates common headers specific to APIs. Can also accept additional headers if demanded by specific APIs.
    ///
    /// - Returns: A configured header JSON dictionary which includes both common and additional params.
    func generateHeader() -> [String: String] {
        var headerDict = [String: String]()
        headerDict["Content-Type"] = "application/json"
        
        return headerDict
    }

}

