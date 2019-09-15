//
//  DefaultHttpPlaintextParser.swift
//  sharedeal
//
//  Created by Eddie Long on 14/09/2019.
//  Copyright © 2019 Eddie Long. All rights reserved.
//

import Foundation

class DefaultHttpPlaintextResponseParser: HttpResponseParser {
    func parse<T>(data: Data, response: HTTPURLResponse) -> Result<T, Error> where T : Decodable {
        if let contentType = response.find(header: "content-type")?.lowercased() {
            if !contentType.contains("text/plain") {
                return .failure(HttpError.invalidContentType(type: contentType))
            }
        }
        
        if T.self as? String.Type != nil {
            return .success(String(data: data, encoding: .utf8) as! T)
        }
        fatalError("Only String types are supported for plain text parsing")
    }
}
