//
//  SharesPrice.swift
//  sharedeal
//
//  Created by Eddie Long on 14/09/2019.
//  Copyright © 2019 Eddie Long. All rights reserved.
//

import Foundation

struct SharesPrice: Codable {
    
    let name: String
    let symbol: String
    let value: Double
    var currency: Currency {
        return .eur
    }
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case symbol = "symbol"
        case value = "value"
    }
}
