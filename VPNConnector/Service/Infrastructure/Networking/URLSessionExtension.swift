//
//  URLSessionExtension.swift
//  VPNConnector
//
//  Created by Yevhen Kyivskyi on 11.07.2021.
//

import Foundation

enum AppErr: Error {
    case unexpected(String)
    case wrongURL
}

struct HttpResult {
    let status: Int
    let data: Data
}

struct HttpError: Error {
    let status: Int
    let data: Data?
    let error: Error?
}

typealias URLSessionCallCompletion = (Result<HttpResult, HttpError>) -> ()

extension URLSession {
    func call(
        _ urlRequest: URLRequest,
        completion: @escaping URLSessionCallCompletion
    ) {
        self.dataTask(with: urlRequest) { data, response, error in
            let res = response as? HTTPURLResponse
            let status = res?.statusCode ?? 500
            let validStatusCode = 200 ... 299
            let isCodeValid = validStatusCode ~= status
            let isValidResponse = error == nil && isCodeValid
            
            if let data = data, isValidResponse {
                completion(.success(HttpResult(status: status, data: data)))
            } else {
                completion(.failure(HttpError(status: status, data: data, error: error)))
            }
        }.resume()
    }

    func call(
        _ urlStr: String,
        completion: @escaping URLSessionCallCompletion
    )  {
        let url = URL(string: urlStr)
        guard let safeUrl = url else {
            completion(.failure(HttpError(status: -2, data: nil, error: AppErr.unexpected("Invalid url: \(urlStr)"))))
            return
        }
        call(URLRequest(url: safeUrl), completion: completion)
    }
}
