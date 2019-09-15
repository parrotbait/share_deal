//
//  DefaultHttpPlaintextParser.swift
//  sharedeal
//
//  Created by Eddie Long on 14/09/2019.
//  Copyright © 2019 Eddie Long. All rights reserved.
//

import Foundation

class DefaultHttpPlaintextResponseParser: HttpResponseParser {
    func parse<T>(data: Data, headers: [AnyHashable : Any]) -> Result<T, Error> where T : Decodable {
        if let contentType = find(header: "content-type", inHeaders: headers)?.lowercased() {
            if !contentType.contains("text/plain") {
                return .failure(HttpError.invalidContentType(type: contentType))
            }
        } else {
            return .failure(HttpError.missingContentType)
        }
        
        if T.self as? String.Type != nil {
            return .success(String(data: data, encoding: .utf8) as! T)
        }
        fatalError("Only String types are supported for plain text parsing")
    }
}
