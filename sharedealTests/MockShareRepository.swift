//
//  MockShareRepository.swift
//  sharedealTests
//
//  Created by Eddie Long on 15/09/2019.
//  Copyright © 2019 Eddie Long. All rights reserved.
//

import Foundation
import RxSwift

@testable import sharedeal

class MockShareSellingRepository: ShareSellingRepository {
    private let service: MockShareService
    private let bag = DisposeBag()
    
    init(service: MockShareService) {
        self.service = service
    }
    func getCertificates() -> Observable<[ShareCertificate]> {
        return service.getCertificates()
    }
    
    var price: Observable<SharesPrice> {
        return _price.compactMap({ $0 }).asObservable()
    }
    private var _price = BehaviorSubject<SharesPrice?>(value: nil)
    
    func getSharesPrice() {
        service.getCurrentPrice().subscribe(onNext: { [weak self] (cert) in
            self?._price.onNext(cert)
            }, onError: { (error) in
                print(error)
        }).disposed(by: bag)
    }
}
