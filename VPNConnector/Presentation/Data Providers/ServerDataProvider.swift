//
//  ServerDataProvider.swift
//  VPNConnector
//
//  Created by Yevhen Kyivskyi on 14.07.2021.
//

import Foundation

typealias ServerDataProviderGetServersCompletion = (Result<[Server], Error>) -> ()

protocol ServerDataProviding {
    
    func getServers(completion: @escaping ServerDataProviderGetServersCompletion)
}

class ServerDataProvider: ServerDataProviding {
    
    private let apiService: ServerApiServicing
    private let persistencyService: PersistencyServicing
    private let reachability: Reachabilable
    
    init(
        apiService: ServerApiServicing = ServerApiService(),
        persistencyService: PersistencyServicing = PersistensyService(),
        reachability: Reachabilable = Reachability()
    ) {
        self.apiService = apiService
        self.persistencyService = persistencyService
        self.reachability = reachability
    }
    
    func getServers(completion: @escaping ServerDataProviderGetServersCompletion) {
        
//        if !isInternetConnectionAvailable(completion: completion) { return }
        
        apiService.getServers { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let servers):
                let backgroundContext = strongSelf.persistencyService.backgroundContext
                backgroundContext.perform {
                    servers.forEach { server in
                        let serverObject = ServerObject(context: backgroundContext)
                        serverObject.update(with: server)
                        
                        let nodeObjects = server.nodes.map { node -> NodeObject in
                            let nodeObject = NodeObject(context: backgroundContext)
                            nodeObject.update(with: node)
                            nodeObject.server = serverObject
                            return nodeObject
                        }
                        
                        serverObject.addToNodes(NSSet(array: nodeObjects))
                    }
                    try? backgroundContext.save()
                 
                    completion(.success(servers))
                }
            case .failure(let error):
                strongSelf.handleError(error, completion: completion)
            }
        }
    }
}

extension ServerDataProvider {
    
    private func handleError(
        _ error: Error,
        completion: @escaping ServerDataProviderGetServersCompletion
    ) {
        guard let networkError = NetworkError(rawValue: (error as NSError).code) else {
            completion(.failure(error))
            return
        }
        switch networkError {
        case .noInternetConnection:
            fetchPersistedServers(completion: completion)
        }
    }
    
    private func fetchPersistedServers(
        completion: @escaping ServerDataProviderGetServersCompletion
    ) {
        do {
            let serverObjects = try persistencyService.fetchObject(ServerObject.fetchRequestAlphabetic())
            let servers = serverObjects.map { $0.domainObject }
            completion(.success(servers))
        } catch {
            completion(.failure(error))
        }
    }
}

