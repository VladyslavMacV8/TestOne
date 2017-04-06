//
//  Articles.swift
//  TestOne
//
//  Created by Vladyslav Kudelia on 3/17/17.
//  Copyright © 2017 Vladyslav Kudelia. All rights reserved.
//

import Foundation
import Moya

private func JSONResponseDataFormatter(_ data: Data) -> Data {
    do {
        let dataAsJSON = try JSONSerialization.jsonObject(with: data)
        let prettyData =  try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
        return prettyData
    } catch {
        return data
    }
}

let provider = MoyaProvider<APIManager>(plugins: [NetworkLoggerPlugin(verbose: true, responseDataFormatter: JSONResponseDataFormatter)])

public enum APIManager {
    case source
    case aricles(String, String, String)
}

extension APIManager: TargetType {
    public var baseURL: URL { return URL(string:"https://newsapi.org/v1")! }
    
    public var path: String {
        switch self {
        case .source:
            return "/sources"
        case .aricles:
            return "/articles"
        }
    }
    
    public var method: Moya.Method {
        return .get
    }

    public var parameters: [String: Any]? {
        var value = [String: Any]()
        switch self {
        case .source:
            return [:]
        case .aricles(let newsId, let sorted, let apiKey):
            value = ["source": newsId, "sortBy": sorted, "apiKey": apiKey]
            return value
        }
    }
    
    public var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }

    public var sampleData: Data {
        switch self {
        case .source:
            return "source".data(using: String.Encoding.utf8)!
        case .aricles:
            return "article".data(using: String.Encoding.utf8)!
        }
    }
    
    public var task: Task {
        return .request
    }

    public var validate: Bool {
        return true
    }
}

public func url(route: TargetType) -> String {
    return route.baseURL.appendingPathComponent(route.path).absoluteString
}

extension Moya.Response {
    func mapDictionary() throws -> [String: AnyObject] {
        let any = try self.mapJSON()
        guard let dict = any as? [String: AnyObject] else {
            throw MoyaError.jsonMapping(self)
        }
        return dict
    }
}
