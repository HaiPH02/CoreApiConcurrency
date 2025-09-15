//
//  CustomError.swift
//  CoreApiConcurrency
//
//  Created by HaiPH on 15/9/25.
//

import Foundation

enum CustomError: LocalizedError {
    case thrownError(Error)
    case customError(String)
    case serverMessage(String)
    case noInternet
    case expiredToken
    case invalidURL
    case invalidInput
    case serverError
    case noData
    case badData
    case unknownError
    case notAvailable
}
