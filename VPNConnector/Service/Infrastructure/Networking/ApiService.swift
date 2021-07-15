//
//  NetworkManager.swift
//  VPNConnector
//
//  Created by Yevhen Kyivskyi on 13.07.2021.
//

import Foundation

typealias ApiServiceCompletion<T: Codable> = (Result<T, Error>) -> ()

protocol ApiServicing {
    func call<T: Codable>(
        request: URLRequest,
        type: T.Type,
        completion: @escaping ApiServiceCompletion<T>
    )
}

class ApiService: ApiServicing {
    
    func call<T: Codable>(
        request: URLRequest,
        type: T.Type,
        completion: @escaping ApiServiceCompletion<T>
    ) {
        URLSession.shared.call(request) { result in
            switch result {
            case .success(let respose):
                let jsonDecoder = JSONDecoder()
                do {
                    let model = try jsonDecoder.decode(T.self, from: respose.data)
                    completion(.success(model))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error.error ?? AppErr.unexpected("Something went wrong")))
            }
        }
    }
}
