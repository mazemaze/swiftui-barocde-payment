//
//  APIError.swift
//  BarcodePayment
//
//  Created by 樋川裕次郎 on 2023/02/20.
//

import Foundation

enum APIError: Error {
    case response
    
    case jsonDecode
    
    case statusCode(statusCode: String)
}

extension APIError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .response:
            return "Response Error"
            
        case .jsonDecode:
            return "json convert failed in JSONDecoder"
            
        case .statusCode(let statusCode):
            return "Error! StatusCode: " + String(statusCode)
        }
    }
}
