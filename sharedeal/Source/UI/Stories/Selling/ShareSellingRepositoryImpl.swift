//
//  ShareSellingRepositoryImpl.swift
//  sharedeal
//
//  Created by Eddie Long on 14/09/2019.
//  Copyright © 2019 Eddie Long. All rights reserved.
//

import Foundation
import RxSwift

class ShareSellingRepositoryImpl: ShareSellingRepository {
    
    private let provider: ServiceProvider
    init(provider: ServiceProvider) {
        self.provider = provider
    }
    
    func getCertificates() -> Observable<[ShareCertificate]> {
        return provider.share.getCertificates()
    }
    
    func getSharesPrice() -> Observable<SharesPrice> {
        return provider.share.getCurrentPrice()
    }
}
