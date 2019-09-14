//
//  ServiceProviderImpl.swift
//  sharedeal
//
//  Created by Eddie Long on 14/09/2019.
//  Copyright © 2019 Eddie Long. All rights reserved.
//

import Foundation

class ServiceProviderImpl: ServiceProvider {
    let http: HttpService
    let share: ShareService
    
    init(environment: Environment) {
        http = HttpServiceImpl(environment: environment)
        share = ShareServiceImpl(http: http)
    }
}
