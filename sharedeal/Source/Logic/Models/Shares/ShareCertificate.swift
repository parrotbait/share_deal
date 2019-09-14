//
//  ShareCertificate.swift
//  sharedeal
//
//  Created by Eddie Long on 14/09/2019.
//  Copyright © 2019 Eddie Long. All rights reserved.
//

import Foundation

struct ShareCertificate: Codable {

    let id: Int
    var numShares: Int
    let issueDate: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "certificateId"
        case numShares = "numberOfShares"
        case issueDate = "issuedDate"
    }
}
