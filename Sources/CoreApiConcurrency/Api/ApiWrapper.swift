//
//  ApiWrapper.swift
//  CoreApiConcurrency
//
//  Created by HaiPH on 15/9/25.
//

import Foundation

public class ApiRepository<T: Codable>: CoreApiRepositoryProtocol {
    
    private let scheme: String = "https"
    private let endPoint: String
    
    init(_ endPoint: String) {
        self.endPoint = endPoint
    }
    
    public func fetchItem(path: String, param: [String : any Codable], needAuthToken: Bool) async throws -> T {
        guard Connectivity.isConnetedToInternet else  {
            throw CustomError.noInternet
        }
        
        let request = try createGetRequest(from: path,
                                           method: .get,
                                           param: param,
                                           needAuthToken: needAuthToken)
        
        do {
            let result = try await URLSession.shared.data(for: request)
            Logger.log(data: result.0, response: result.1, error: nil)
            
            let response = result.1
            let data = result.0
            
            try handleStatusCode(from: response)
            
            let decodeObject = try decode(from: data)
            return decodeObject
        } catch let error {
            Logger.log(data: nil, response: nil, error: error)
            if error is CustomError {
                throw error
            } else {
                throw CustomError.serverError
            }
        }
        
    }
}

extension ApiRepository {
    private func handleStatusCode(from response: URLResponse) throws {
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
            throw CustomError.serverError
        }
        
        if statusCode == 500 {
            throw CustomError.serverError
        }
        
        if statusCode < 300 {
            return
        }
    }
    
    private func decode(from data: Data) throws -> T {
        do {
            let decodedObject = try JSONDecoder().decode(T.self, from: data)
            return decodedObject
        } catch let DecodingError.dataCorrupted(context) {
            throw CustomError.customError("\(context.debugDescription) at \(context.codingPath)")
        } catch let DecodingError.keyNotFound(key, context) {
            throw CustomError.customError("Key '\(key)' not found: \(context.debugDescription) at \(context.codingPath)")
        } catch let DecodingError.valueNotFound(value, context) {
            throw CustomError.customError("Value '\(value)' not found: \(context.debugDescription) at \(context.codingPath)")
        } catch let DecodingError.typeMismatch(type, context)  {
            throw CustomError.customError("Type '\(type)' mismatch: \(context.debugDescription) at \(context.codingPath)")
        } catch {
            throw CustomError.badData
        }
    }
    
    private func createGetRequest(from path: String,
                                  method: HTTPMethod,
                                  param: [String: any Codable],
                                  needAuthToken: Bool) throws -> URLRequest {
        var components = URLComponents()
        components.scheme = scheme
        components.host = endPoint
        components.path = path
        
        components.queryItems = param
            .map { URLQueryItem(name: $0.key, value: String(describing: "\($0.value)")) }
        
        guard let safeURL = components.url else {
            throw CustomError.badData
        }
        
        // Form the URL request
        var request = URLRequest(url: safeURL, timeoutInterval: 20.0)
        
        // Specify the http method and allow JSON returns
        request.httpMethod = method.rawValue
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        
        // Add the authorization token if provided
//        if needAuthToken {
//            if let authToken = try KeychainManager.shared.retrieveToken() {
//                request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
//            }
//        }
        Logger.log(request: request)
        // Return the result
        return request
    }
}
