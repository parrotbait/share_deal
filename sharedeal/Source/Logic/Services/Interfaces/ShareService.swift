//
//  ShareService.swift
//  sharedeal
//
//  Created by Eddie Long on 14/09/2019.
//  Copyright © 2019 Eddie Long. All rights reserved.
//

import Foundation
import RxSwift

protocol ShareService {
    func getCertificates() -> Observable<[ShareCertificate]>
    func getCurrentPrice() -> Observable<SharesPrice>
}
