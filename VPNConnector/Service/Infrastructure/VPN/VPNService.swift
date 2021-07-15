//
//  VPNService.swift
//  VPNConnector
//
//  Created by Yevhen Kyivskyi on 13.07.2021.
//

import NetworkExtension

typealias VPNServiceConnectCompletion = (Result<NEVPNStatus, Error>) -> ()
typealias VPNServiceStatusObserver = (NEVPNStatus) -> ()

protocol VPNServicing: AnyObject {
    
    var status: NEVPNStatus { get }
    
    func connect(to node: Node, of server: Server, completion: @escaping VPNServiceConnectCompletion)
    func disconnect()
}

class VPNService: VPNServicing {
    
    private enum Constants {
        static let password = "xpcnwg6abh"
        static let username = "prd_test_j4d3vk6"
        
        static let passwordKey = "vpn_password"
    }
    
    private let vpnManager = NEVPNManager.shared()
    private let keychainService: KeychainServicing
    
    var status: NEVPNStatus {
        return vpnManager.connection.status
    }
    
    init(
        keychainService: KeychainServicing = KeychainService()
    ) {
        self.keychainService = keychainService

        try? keychainService.setValue(
            Constants.password,
            query: keychainService.genericPasswordQuery,
            for: Constants.passwordKey
        )
    }
    
    func connect(
        to node: Node,
        of server: Server,
        completion: @escaping VPNServiceConnectCompletion
    ) {
        
        let proto = VPNProtocolFactory.ikev2Protocol
        proto.username = Constants.username
        proto.passwordReference = try? keychainService.getValue(
            query: keychainService.genericPasswordQuery,
            for: Constants.passwordKey
        )
        proto.serverAddress = node.hostname
        proto.remoteIdentifier = server.dnsHostname
        
        vpnManager.protocolConfiguration = proto
        
        vpnManager.loadFromPreferences { [weak self] error in
            guard let strongSelf = self else { return }
            if let error = error {
                completion(.failure(error))
            }
            strongSelf.vpnManager.isEnabled = true
            do {
                try strongSelf.vpnManager.connection.startVPNTunnel()
                completion(.success(strongSelf.vpnManager.connection.status))
            } catch let connectionError {
                completion(.failure(connectionError))
            }
        }
    }
    
    func disconnect() {
        vpnManager.connection.stopVPNTunnel()
    }
}

class VPNProtocolFactory {
    
    static var ikev2Protocol: NEVPNProtocolIKEv2 {
        
        let ikev2Protocol = NEVPNProtocolIKEv2()
        
        ikev2Protocol.useExtendedAuthentication = true
        ikev2Protocol.ikeSecurityAssociationParameters.encryptionAlgorithm =  NEVPNIKEv2EncryptionAlgorithm.algorithmAES256GCM
        ikev2Protocol.ikeSecurityAssociationParameters.diffieHellmanGroup = NEVPNIKEv2DiffieHellmanGroup.group21
        ikev2Protocol.ikeSecurityAssociationParameters.integrityAlgorithm = NEVPNIKEv2IntegrityAlgorithm.SHA256
        ikev2Protocol.ikeSecurityAssociationParameters.lifetimeMinutes = 1440
        ikev2Protocol.childSecurityAssociationParameters.encryptionAlgorithm =  NEVPNIKEv2EncryptionAlgorithm.algorithmAES256GCM
        ikev2Protocol.childSecurityAssociationParameters.diffieHellmanGroup = NEVPNIKEv2DiffieHellmanGroup.group21
        ikev2Protocol.childSecurityAssociationParameters.integrityAlgorithm = NEVPNIKEv2IntegrityAlgorithm.SHA256
        ikev2Protocol.childSecurityAssociationParameters.lifetimeMinutes = 1440
        return ikev2Protocol
    }
}



