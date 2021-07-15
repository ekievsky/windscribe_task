//
//  NodeObject+DomainMapping.swift
//  VPNConnector
//
//  Created by Yevhen Kyivskyi on 14.07.2021.
//

import Foundation

extension NodeObject {
    var domainObject: Node {
        return Node(
            ip: ip ?? "",
            ip2: ip2 ?? "",
            ip3: ip3 ?? "",
            hostname: hostname ?? "",
            weight: Int(weight),
            group: group ?? "",
            gps: gps ?? "",
            tz: tz ?? "",
            type: type ?? "",
            wgPubkey: wgPubkey ?? "",
            proOnly: Int(proOnly)
        )
    }
}
