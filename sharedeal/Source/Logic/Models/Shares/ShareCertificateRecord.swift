//
//  ShareCertificateRecord.swift
//  sharedeal
//
//  Created by Eddie Long on 14/09/2019.
//  Copyright © 2019 Eddie Long. All rights reserved.
//

import Foundation
import RxSwift

class ShareCertificateRecord {
    let cert: ShareCertificate
    init (cert: ShareCertificate) {
        self.cert = cert
        
        numberOfShares = BehaviorSubject(value: cert.numShares)
        numberOfSharesSelling = BehaviorSubject(value: 0)
        
    }
    
    var numberOfShares: BehaviorSubject<Int>
    var numberOfSharesSelling: BehaviorSubject<Int>
}
