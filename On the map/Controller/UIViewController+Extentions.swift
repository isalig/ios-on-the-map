//
//  UIViewController+Extentions.swift
//  On the map
//
//  Created by Ischuk Alexander on 31.05.2020.
//  Copyright © 2020 Ischuk Alexander. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func showAlert(alertMessage: ApiClient.AlertMessage, buttonTitle: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: alertMessage.title, message: alertMessage.message, preferredStyle: .alert)
            let alertAction = UIAlertAction(title: buttonTitle, style: .default) { action in
                alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(alertAction)
            self.present(alert, animated: true)
        }
    }
}
