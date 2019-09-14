//
//  Data.swift.swift
//  sharedeal
//
//  Created by Eddie Long on 14/09/2019.
//  Copyright © 2019 Eddie Long. All rights reserved.
//

import Foundation

extension Data {
    mutating public func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
