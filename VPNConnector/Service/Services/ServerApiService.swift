//
//  ServerApiService.swift
//  VPNConnector
//
//  Created by Yevhen Kyivskyi on 13.07.2021.
//

import Foundation

typealias ServerApiServiceGetServersCompletion = (Result<[Server], Error>) -> ()

protocol ServerApiServicing {
    func getServers(completion: @escaping ServerApiServiceGetServersCompletion)
}

class ServerApiService: ServerApiServicing {
    
    private let apiService: ApiServicing
    
    init(apiService: ApiServicing = ApiService()) {
        self.apiService = apiService
    }
    
    func getServers(
        completion: @escaping ServerApiServiceGetServersCompletion
    ) {
        
        guard let request = ServerApiRoute.serverList.asURLRequest() else {
            completion(.failure(AppErr.wrongURL))
            return
        }
        
        apiService.call(request: request, type: DataContainer<[Server]>.self) { result in
            switch result {
            case .success(let container):
                let servers = container.data.sorted(by: { $0.name < $1.name })
                completion(.success(servers))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
