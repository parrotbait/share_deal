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
    case sellShares(shares: [ShareCertificateSale])
    var baseURL: String? {
        switch self {
        case .getPrice, .getCertificates:
            return nil
        case .sellShares:
            return "https://webhook.site"
        }
    }
    
    var path: String {
        switch self {
        case .getCertificates:
            return "/test/sampledata"
        case .getPrice:
            return "/test/fmv"
        case .sellShares:
            return "/fe41e3f9-6d54-46f4-a095-701953ad6161"
        }
    }
    
    var method: HttpMethod {
        switch self {
        case .getCertificates, .getPrice:
            return .get
        case .sellShares:
            return .post
        }
    }
    
    var headers: [String : Any]? { return nil }
    var query: [String : Any]? { return nil }
    var body: [String : Any]? {
        switch self {
        case .getPrice, .getCertificates:
            return nil
        case .sellShares(let shares):
            guard let data = try? JSONEncoder().encode(shares) else { return ["shares": []] }
            let result = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 }
            guard let body = result else { return ["shares": []] }
            return ["shares": body]
        }
    }
        
    var formData: [String : Any]? { return nil }
    var file: [HttpMultipartFile]? { return nil }
    var filename: String? { return nil }
    var mimeType: String? { return nil }
    var parser: HttpResponseParser? {
        switch self {
        case .getPrice, .getCertificates:
            return nil
        case .sellShares:
            return DefaultHttpPlaintextResponseParser()
        }
    }
}
