//
//  ShareCertificateSale.swift
//  sharedeal
//
//  Created by Eddie Long on 14/09/2019.
//  Copyright © 2019 Eddie Long. All rights reserved.
//

import Foundation

struct ShareCertificateSale: Codable {
    let id: Int
    let numberOfShares: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case numberOfShares = "number_of_shares"
    }
}
