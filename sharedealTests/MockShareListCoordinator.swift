//
//  MockShareListCoordinator.swift
//  sharedealTests
//
//  Created by Eddie Long on 15/09/2019.
//  Copyright © 2019 Eddie Long. All rights reserved.
//

import Foundation

@testable import sharedeal

class MockShareListCoordinator: ShareSellingListCoordinator {
    var showedDialog = false
    var record: ShareCertificateRecord?
    func showSellDialog(repo: ShareSellingRepository, record: ShareCertificateRecord) {
        self.showedDialog = true
        self.record = record
    }
}
