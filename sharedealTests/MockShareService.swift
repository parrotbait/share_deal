//
//  MockShareService.swift
//  sharedealTests
//
//  Created by Eddie Long on 15/09/2019.
//  Copyright © 2019 Eddie Long. All rights reserved.
//

import Foundation
import RxSwift

@testable import sharedeal

final class MockShareService: ShareService {
    
    var certificates = [ShareCertificate]()
    var sellingCerts = [ShareCertificateSale]()
    var price =  SharesPrice.init(name: "", symbol: "", value: 0.0)
    func getCertificates() -> Observable<[ShareCertificate]> {
        return Observable.just(certificates)
    }
    func getCurrentPrice() -> Observable<SharesPrice> {
        return Observable.just(price)
    }
    func sellShares(items: [ShareCertificateSale]) -> Observable<Void> {
        sellingCerts = items
        return Observable.just(())
    }
}
