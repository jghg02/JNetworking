//
//  JNNetworkError.swift
//  
//
//  Created by Josue Hernandez on 02-07-22.
//

import Foundation

public enum JNNetworkError<T: LocalizedError>: LocalizedError {
    case failedRequest(URLError?)
    case invalidRequest(T)
    case invalidResponse(Int)
    case responseTypeMismatch
    
    public var errorDescription: String? {
        switch self {
            case .failedRequest:
                return "The request failed."
            case let .invalidRequest(error):
                return error.localizedDescription
            case let .invalidResponse(statusCode):
                return "The response was invalid (\(statusCode))."
            case .responseTypeMismatch:
                return "The response did not match the expected type."
        }
    }

    public var failureReason: String? {
        switch self {
            case let .failedRequest(error):
                return error?.localizedDescription
            case let .invalidRequest(error):
                return error.localizedDescription
            case let .invalidResponse(statusCode):
                return "The server returned a \(statusCode) status code."
            case .responseTypeMismatch:
                return "The response did not match the expected error type."
        }
    }
    
}

extension JNNetworkError: Equatable where T: Equatable {}
