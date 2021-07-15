//
//  ServerApiRoute.swift
//  VPNConnector
//
//  Created by Yevhen Kyivskyi on 13.07.2021.
//

import Foundation

enum ServerApiRoute: APIRoutable {
    case serverList
    
    var method: HTTPMethod {
        return .get
    }
    
    var path: String {
        return "serverlist/ikev2/1/89yr4y78r43gyue4gyut43guy"
    }
}
