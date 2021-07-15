//
//  ServerListTableViewCell.swift
//  VPNConnector
//
//  Created by Yevhen Kyivskyi on 13.07.2021.
//

import UIKit

class ServerListTableViewCell: UITableViewCell {
    
    static var identifier: String {
        return String(describing: String(describing: ServerListTableViewCell.self))
    }
    
    @IBOutlet private var serverTitleLabel: UILabel!
    
    func configure(with server: Server) {
        serverTitleLabel.text = server.name
    }
}
