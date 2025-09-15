//
//  Connectivity.swift
//  CoreApiConcurrency
//
//  Created by HaiPH on 15/9/25.
//

import Foundation
import Alamofire

struct Connectivity {
    static let shareInstance = NetworkReachabilityManager()
    
    static var isConnetedToInternet: Bool {
        if let shareInstance = shareInstance {
            return shareInstance.isReachable
        }
        return false
    }
}
