//
//  UIViewControllerExtension.swift
//  VPNConnector
//
//  Created by Yevhen Kyivskyi on 14.07.2021.
//

import UIKit

extension UIViewController {
    
    func showAlert(title: String? = "Error", message: String, onOk: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .destructive) { _ in onOk?() })
        self.present(alert, animated: true, completion: nil)
    }
}
