//
//  UIViewController.swift
//  sharedeal
//
//  Created by Eddie Long on 14/09/2019.
//  Copyright © 2019 Eddie Long. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func showError(_ error: Error) {
        let alert = UIAlertController(title: R.string.localizable.common_error_title(),
                                      message: error.localizedDescription,
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: R.string.localizable.common_ok_button(),
                                      style: UIAlertAction.Style.default,
                                      handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
