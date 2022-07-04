//
//  ApiModelHelper.swift
//  
//
//  Created by Josue Hernandez on 01-07-22.
//

import Foundation
import JNetworking


struct ApiModelHelperConstants {
    static let baseURL = "https://example.com"
    static let recipes = "/ios"
}

struct ApiModelHelperQueyParams {

}

/// This API will hold all API's related to HF
enum ApiHelper {
    case getData
}

extension ApiHelper: APIProtocol {

    func httpMthodType() -> HTTPMethodType {
        var httpMethodType = HTTPMethodType.get
        switch self {
        case .getData:
            httpMethodType = .get
        }
        return httpMethodType
    }

    func apiEndPath() -> String {
        var path = ""
        switch self {
        case .getData:
            path += ApiModelHelperConstants.recipes
        }

        return path
    }

    func apiBasePath() -> String {
        switch self {
        case .getData:
            return ApiModelHelperConstants.baseURL
        }
    }


}


