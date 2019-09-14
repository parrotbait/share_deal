//
//  ShareSellListCoordinator.swift
//  sharedeal
//
//  Created by Eddie Long on 14/09/2019.
//  Copyright © 2019 Eddie Long. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

protocol ShareSellingListCoordinator {
    func showSellDialog(repo: ShareSellingRepository, record: ShareCertificateRecord)
}

class ShareSellingListCoordinatorImpl: ShareSellingListCoordinator {
    weak var viewController: UIViewController?
    
    init(vc: UIViewController) {
        self.viewController = vc
    }
    func showSellDialog(repo: ShareSellingRepository, record: ShareCertificateRecord) {
        let vc = SellShareDialog()
        let viewModel = SellShareDialogViewModel(repo: repo, record: record)
        vc.viewModel = viewModel
        viewController?.present(vc, animated: true, completion: nil)
    }
}
