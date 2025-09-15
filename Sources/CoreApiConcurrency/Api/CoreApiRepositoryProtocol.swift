//
//  CoreApiRepositoryProtocol.swift
//  CoreApiConcurrency
//
//  Created by HaiPH on 15/9/25.
//

import Foundation

public protocol CoreApiRepositoryProtocol {
    associatedtype T
    
    func fetchItem(path: String,
                   param: [String: any Codable],
                   needAuthToken: Bool) async throws -> T
}
