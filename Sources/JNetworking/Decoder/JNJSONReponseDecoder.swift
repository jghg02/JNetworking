//
//  JNJSONResponseDecoder.swift
//  
//
//  Created by Josue German Hernandez Gonzalez on 20-07-21.
//

import Foundation

public class JNJSONResponseDecoder {

    public typealias JNJSONDecodeCompletion<T> = (T?, Error?) -> Void
    
    public static func decodeFrom<T: Codable>(_ responseData: Data, returningModelType: T.Type, completion: JNJSONDecodeCompletion<T>, decodingStrategy: JSONDecoder.KeyDecodingStrategy?) {
        do {
            let decoder = JSONDecoder()
            let model = try decoder.decode(returningModelType, from: responseData)
            if decodingStrategy != nil {
                decoder.keyDecodingStrategy = decodingStrategy!
            }
            completion(model, nil)
        } catch let DecodingError.dataCorrupted(context) {
            print("Data corrupted: ", context)
            completion(nil, DecodingError.dataCorrupted(context))
        } catch let DecodingError.keyNotFound(key, context) {
            print("Key '\(key)' not found: ", context.debugDescription, "\n codingPath:", context.codingPath)
            completion(nil, DecodingError.keyNotFound(key, context))
        } catch let DecodingError.valueNotFound(value, context) {
            print("Value '\(value)' not found: ", context.debugDescription, "\n codingPath:", context.codingPath)
            completion(nil, DecodingError.valueNotFound(value, context))
        } catch let DecodingError.typeMismatch(type, context) {
            print("Type '\(type)' mismatch: ", context.debugDescription, "\n codingPath:", context.codingPath)
            completion(nil, DecodingError.typeMismatch(type, context))
        } catch {
            print("error: ", error.localizedDescription)
            completion(nil, error)
        }
    }
}

