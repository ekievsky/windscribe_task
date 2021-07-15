//
//  NetworkTypes.swift
//  VPNConnector
//
//  Created by Yevhen Kyivskyi on 11.07.2021.
//

import Foundation

enum NetworkError: Int {
    case noInternetConnection = -1009
}

enum HTTPMethod: String {
    case get = "GET"
}

struct URLHeader {
    let value: String
    let httpHeaderField: String
}


protocol APIRoutable {

    var method: HTTPMethod { get }
    var path: String { get }
    var urlString: String { get }
}

extension APIRoutable {

    var urlString: String {
        return "https://assets.windscribe.com/\(path)"
    }

    func asURLRequest() -> URLRequest? {
        guard let url = URL(string: urlString) else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue

        return request
    }
}
