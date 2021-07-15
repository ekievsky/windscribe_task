//
//  Reachability.swift
//  VPNConnector
//
//  Created by Yevhen Kyivskyi on 14.07.2021.
//

import Network

protocol Reachabilable {
    
    var currentStatus: NWPath.Status { get }
}

class Reachability: Reachabilable {

    private let monitor = NWPathMonitor()
    
    var currentStatus: NWPath.Status {
        return monitor.currentPath.status
    }
}
