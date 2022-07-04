//
//  JNResponse.swift
//  
//
//  Created by Josue Hernandez on 01-07-22.
//

import Foundation

public struct JNResponse<T> {
    public let headers: [AnyHashable: Any]
    public let value: T
}
