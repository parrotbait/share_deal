//
//  ShareCellViewModel.swift
//  sharedeal
//
//  Created by Eddie Long on 14/09/2019.
//  Copyright © 2019 Eddie Long. All rights reserved.
//

import Foundation
import RxSwift

class ShareCellViewModel {
    
    private let data: ShareCertificate
    init(data: ShareCertificate) {
        self.data = data
    }
    
    var name: Observable<String> {
        return Observable.just("Certificate # \(data.id)")
    }
    
    var numberShares: Observable<String> {
        return Observable.just("\(data.numShares)")
    }
}
