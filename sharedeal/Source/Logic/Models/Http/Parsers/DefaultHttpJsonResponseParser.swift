//
//  DefaultJsonParser.swift
//  sharedeal
//
//  Created by Eddie Long on 14/09/2019.
//  Copyright © 2019 Eddie Long. All rights reserved.
//

import Foundation

// Public for testing purposes
func customDateParser(_ decoder: Decoder) throws -> Date {
    let dateString = try decoder.singleValueContainer().decode(String.self)
    let scanner = Scanner(string: dateString)
    var millis: Int64 = 0
    if scanner.scanString("/Date(", into: nil) &&
        scanner.scanInt64(&millis) &&
        scanner.scanInt(nil) &&
        scanner.scanString(")/", into: nil) &&
        scanner.isAtEnd {
        return Date(timeIntervalSince1970: TimeInterval(millis) / 1000)
    }
    // TODO: this is pretty unsatisfcatory
    return Date(timeIntervalSince1970: 0)
}

class DefaultHttpJsonResponseParser: HttpResponseParser {
    func parse<T>(data: Data, response: HTTPURLResponse) -> Result<T, Error> where T : Decodable {
        // TODO: Add tests
        if let contentType = response.find(header: "content-type")?.lowercased() {
            if !contentType.contains("application/json") {
                return .failure(HttpError.invalidContentType(type: contentType))
            }
        }
        
        let decoder = JSONDecoder()
        // The backend returns a wacky date format
        // We parse this date here
        decoder.dateDecodingStrategy = .custom(customDateParser)
        do {
            let response = try decoder.decode(T.self, from: data)
            return .success(response)
        } catch {
            print(error)
            return .failure(HttpError.jsonDecodeError(error: error))
        }
    }
}
