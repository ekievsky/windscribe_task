//
//  ViewController.swift
//  VPNConnector
//
//  Created by Yevhen Kyivskyi on 13.07.2021.
//

import UIKit

class ServersListViewController: UIViewController {
    
    @IBOutlet private var tableView: UITableView!
    private var refreshControl: UIRefreshControl!
    
    private let serverDataProvider: ServerDataProviding
    
    private var servers: [Server] = []
    
    init(
        serverDataProvider: ServerDataProviding = ServerDataProvider()
    ) {
        self.serverDataProvider = serverDataProvider
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Servers"
        setupTableView()
        getData()
    }
    
    private func setupTableView() {
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(
            UINib(nibName: ServerListTableViewCell.identifier, bundle: nil),
            forCellReuseIdentifier: ServerListTableViewCell.identifier)
        
        refreshControl = UIRefreshControl()
        let action = UIAction { _ in
            self.getData()
        }
        refreshControl.addAction(action, for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func getData() {
        refreshControl.beginRefreshing()
        serverDataProvider.getServers { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let servers):
                strongSelf.servers = servers
                DispatchQueue.main.async {
                    strongSelf.tableView.reloadData()
                    strongSelf.refreshControl.endRefreshing()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    strongSelf.showAlert(message: error.localizedDescription)
                    strongSelf.refreshControl.endRefreshing()
                }
            }
            
        }
    }
}

extension ServersListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return servers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ServerListTableViewCell.identifier,
            for: indexPath
        ) as! ServerListTableViewCell
        cell.configure(with: servers[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
        let nodesViewController = NodesListViewController(server: servers[indexPath.row])
        navigationController?.pushViewController(nodesViewController, animated: true)
    }
}
