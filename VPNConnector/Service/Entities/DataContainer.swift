//
//  Data.swift
//  VPNConnector
//
//  Created by Yevhen Kyivskyi on 13.07.2021.
//

import Foundation

struct DataContainer<T: Codable>: Codable {
    let data: T
}
