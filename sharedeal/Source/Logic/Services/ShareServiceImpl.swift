//
//  ShareServiceImpl.swift
//  sharedeal
//
//  Created by Eddie Long on 14/09/2019.
//  Copyright © 2019 Eddie Long. All rights reserved.
//

import Foundation
import RxSwift

class ShareServiceImpl: ShareService {
    
    private let http: HttpService
    init(http: HttpService) {
        self.http = http
    }
    
    func getCertificates() -> Observable<[ShareCertificate]> {
        let request = ShareRequest.getCertificates
        return http.execute(request: request)
    }
    
    func getCurrentPrice() -> Observable<SharesPrice> {
        let request = ShareRequest.getPrice
        return http.execute(request: request)
    }
    
    func sellShares(items: [ShareCertificateSale]) -> Observable<Void> {
        let request = ShareRequest.sellShares(shares: items)
        return http.execute(request: request).map({ (result: String) -> Void in
            print (result)
            return ()
        })
    }
}
