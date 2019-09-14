//
//  HttpJSONParser.swift
//  sharedeal
//
//  Created by Eddie Long on 14/09/2019.
//  Copyright © 2019 Eddie Long. All rights reserved.
//

import Foundation

protocol HttpResponseParser {
    func parse<T>(data: Data, response: HTTPURLResponse) -> Result<T, Error> where T: Decodable
}
