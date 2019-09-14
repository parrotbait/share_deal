//
//  ShareRequest.swift
//  sharedeal
//
//  Created by Eddie Long on 14/09/2019.
//  Copyright © 2019 Eddie Long. All rights reserved.
//

import Foundation

enum ShareRequest: HttpRequest {
    case getCertificates
    case getPrice
    
    var path: String {
        switch self {
        case .getCertificates:
            return "/test/sampledata"
        case .getPrice:
            return "/test/fmv"
        }
    }
    
    var method: HttpMethod {
        return .get
    }
    
    var headers: [String : Any]? { return nil }
    var query: [String : Any]? { return nil }
    var body: [String : Any]? { return nil }
    var formData: [String : Any]? { return nil }
    var file: [HttpMultipartFile]? { return nil }
    var filename: String? { return nil }
    var mimeType: String? { return nil }
}
