//
//  KeychainService.swift
//  VPNConnector
//
//  Created by Yevhen Kyivskyi on 13.07.2021.
//

import Foundation

enum KeychainServiceError: Error {
    case stringToDataConversionError
    case dataToStringConversionError
    case unhandledError(message: String)
}

protocol KeychainServicing {
    
    var genericPasswordQuery: [String: Any] { get }
    
    func setValue(_ value: String, query: [String: Any], for userAccount: String) throws
    func getValue(query: [String: Any], for userAccount: String) throws -> Data
}

class KeychainService: KeychainServicing {
    
    var genericPasswordQuery: [String: Any] {
        var query: [String: Any] = [:]
        query[String(kSecClass)] = kSecClassGenericPassword
        query[String(kSecAttrService)] = "VPNConnector"
        #if !targetEnvironment(simulator)
            query[String(kSecAttrAccessGroup)] = ""
        #endif
        return query
    }
    
    func setValue(
        _ value: String,
        query: [String: Any],
        for userAccount: String
    ) throws {
        guard let encodedPassword = value.data(using: .utf8) else {
            throw KeychainServiceError.stringToDataConversionError
        }
        var query = query
        query[String(kSecAttrAccount)] = userAccount
        
        var status = SecItemCopyMatching(query as CFDictionary, nil)
        switch status {
        case errSecSuccess:
            var attributesToUpdate: [String: Any] = [:]
            attributesToUpdate[String(kSecValueData)] = encodedPassword
            
            status = SecItemUpdate(query as CFDictionary,
                                   attributesToUpdate as CFDictionary)
            if status != errSecSuccess {
                throw error(query: query, from: status)
            }
        case errSecItemNotFound:
            query[String(kSecValueData)] = encodedPassword
            
            status = SecItemAdd(query as CFDictionary, nil)
            if status != errSecSuccess {
                throw error(query: query, from: status)
            }
        default:
            throw error(query: query, from: status)
        }
    }
    
    func getValue(
        query: [String: Any],
        for userAccount: String
    ) throws -> Data {
        var query = query
        query[String(kSecMatchLimit)] = kSecMatchLimitOne
        query[String(kSecReturnAttributes)] = kCFBooleanTrue
        query[String(kSecReturnData)] = kCFBooleanTrue
        query[String(kSecAttrAccount)] = userAccount
        
        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, $0)
        }
        
        switch status {
        case errSecSuccess:
            guard
                let queriedItem = queryResult as? [String: Any],
                let passwordData = queriedItem[String(kSecValueData)] as? Data
            else {
                throw KeychainServiceError.dataToStringConversionError
            }
            return passwordData
        default:
            throw error(query: query, from: status)
        }
    }
    
    private func error(query: [String: Any], from status: OSStatus) -> KeychainServiceError {
        let message = SecCopyErrorMessageString(status, nil) as String? ?? NSLocalizedString("Unhandled Error", comment: "")
        return KeychainServiceError.unhandledError(message: message)
    }
}
