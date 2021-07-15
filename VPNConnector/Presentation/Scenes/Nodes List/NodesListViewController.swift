//
//  NodesListViewController.swift
//  VPNConnector
//
//  Created by Yevhen Kyivskyi on 14.07.2021.
//

import UIKit

class NodesListViewController: UIViewController {
    
    @IBOutlet private var tableView: UITableView!
    
    private let server: Server
    
    private let vpnService: VPNServicing
    
    init(
        server: Server,
        vpnService: VPNServicing = VPNService()
    ) {
        self.server = server
        self.vpnService = vpnService
        super.init(nibName: nil, bundle: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(connectionStatusChanged(notification:)), name: NSNotification.Name.NEVPNStatusDidChange, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        title = server.name
    }

    private func setupTableView() {
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(
            UINib(nibName: NodeListTableViewCell.identifier, bundle: nil),
            forCellReuseIdentifier: NodeListTableViewCell.identifier)
    }

}

extension NodesListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return server.nodes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: NodeListTableViewCell.identifier,
            for: indexPath
        ) as! NodeListTableViewCell
        cell.configure(with: server.nodes[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
        connectToVpn(at: indexPath)
    }
}

extension NodesListViewController {
    
    func connectToVpn(at indexPath: IndexPath) {
        let node = server.nodes[indexPath.row]
        vpnService.connect(to: node, of: server) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let status):
                strongSelf.showAlert(
                    message: "Connected to \(strongSelf.server.name): \(node.hostname). Status: \(status)"
                )
            case .failure(let error):
                strongSelf.showAlert(message: error.localizedDescription)
            }
        }
    }
}

extension NodesListViewController {
    
    @objc
    private func connectionStatusChanged(notification: Notification) {
        switch vpnService.status {
        case .connecting: title = "Connected to \(server.name)"
        case .reasserting: title = "Reasserting to \(server.name)"
        case .disconnecting: title = "Disconnecting from \(server.name)"
        case .disconnected: title = "Disconnected from \(server.name)"
        default: title = "Invalid status of VPN connection"
        }
    }
}

