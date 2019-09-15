//
//  MockProvider.swift
//  sharedealTests
//
//  Created by Eddie Long on 15/09/2019.
//  Copyright © 2019 Eddie Long. All rights reserved.
//

import Foundation

@testable import sharedeal

class MockProvider: ServiceProvider {
    var http: HttpService
    var share: ShareService
    init (http: HttpService, share: ShareService) {
        self.http = http
        self.share = share
    }
}
