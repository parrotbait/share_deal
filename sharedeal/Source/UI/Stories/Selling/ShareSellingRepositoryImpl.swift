//
//  ShareSellingRepositoryImpl.swift
//  sharedeal
//
//  Created by Eddie Long on 14/09/2019.
//  Copyright © 2019 Eddie Long. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class ShareSellingRepositoryImpl: ShareSellingRepository {
    
    private let provider: ServiceProvider
    private let bag = DisposeBag()
    init(provider: ServiceProvider) {
        self.provider = provider
    }
    
    func getCertificates() -> Observable<[ShareCertificate]> {
        return provider.share.getCertificates()
    }
    
    var price: Observable<SharesPrice> {
        return _price.compactMap({ $0 }).asObservable()
    }
    private var _price = BehaviorSubject<SharesPrice?>(value: nil)
    
    func getSharesPrice() {
        provider.share.getCurrentPrice().subscribe(onNext: { [weak self] (cert) in
            self?._price.onNext(cert)
        }, onError: { [weak self] (error) in
            self?._price.onError(error)
        }).disposed(by: bag)
    }
}
