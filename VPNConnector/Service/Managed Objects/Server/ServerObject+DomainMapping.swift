//
//  ServerObject+DomainMapping.swift
//  VPNConnector
//
//  Created by Yevhen Kyivskyi on 14.07.2021.
//

import Foundation

extension ServerObject {
    var domainObject: Server {
        return Server(
            id: Int(id),
            name: name ?? "",
            countryCode: countryCode ?? "",
            status: Int(status),
            premiumOnly: Int(premiumOnly),
            shortName: shortName  ?? "",
            p2P: Int(p2p),
            tz: tz ?? "",
            tzOffset: tzOffset ?? "",
            locType: locType ?? "",
            forceExpand: Int(forceExpand),
            dnsHostname: dnsHostname ?? "",
            nodes: (nodes?.allObjects as? [NodeObject])?.map { $0.domainObject } ?? []
        )
    }
}
