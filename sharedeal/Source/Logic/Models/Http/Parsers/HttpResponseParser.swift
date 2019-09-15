//
//  HttpJSONParser.swift
//  sharedeal
//
//  Created by Eddie Long on 14/09/2019.
//  Copyright © 2019 Eddie Long. All rights reserved.
//

import Foundation

func find(header: String, inHeaders headers: [AnyHashable : Any]) -> String? {
    let keyValues = headers.map { (String(describing: $0.key).lowercased(), String(describing: $0.value)) }
    return keyValues.first(where: { $0.0 == header.lowercased() })?.1
}

protocol HttpResponseParser {
    func parse<T>(data: Data, headers: [AnyHashable : Any]) -> Result<T, Error> where T: Decodable
}

