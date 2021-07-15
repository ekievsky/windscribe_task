//
//  Node.swift
//  VPNConnector
//
//  Created by Yevhen Kyivskyi on 11.07.2021.
//

import Foundation

struct Node: Codable {
    
    let ip: String
    let ip2: String
    let ip3: String
    let hostname: String
    let weight: Int
    let group: String
    let gps: String
    let tz: String
    let type: String
    let wgPubkey: String
    let proOnly: Int

    enum CodingKeys: String, CodingKey {
        case ip, ip2, ip3, hostname, weight, group, gps, tz, type
        case wgPubkey = "wg_pubkey"
        case proOnly = "pro_only"
    }
}
