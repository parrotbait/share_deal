//
//  ServiceProvider.swift
//  sharedeal
//
//  Created by Eddie Long on 14/09/2019.
//  Copyright © 2019 Eddie Long. All rights reserved.
//

import Foundation

protocol ServiceProvider {
    var http: HttpService { get }
    var share: ShareService { get }
}
