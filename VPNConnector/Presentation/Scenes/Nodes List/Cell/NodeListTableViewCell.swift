//
//  NodeListTableViewCell.swift
//  VPNConnector
//
//  Created by Yevhen Kyivskyi on 14.07.2021.
//

import UIKit

class NodeListTableViewCell: UITableViewCell {
    
    static var identifier: String {
        return String(describing: String(describing: NodeListTableViewCell.self))
    }

    @IBOutlet private var nodeTitleLabel: UILabel!
    
    func configure(with node: Node) {
        self.nodeTitleLabel.text = node.hostname
    }
}
