//
//  HttpRequest.swift
//  sharedeal
//
//  Created by Eddie Long on 14/09/2019.
//  Copyright © 2019 Eddie Long. All rights reserved.
//

import Foundation

struct HttpMultipartFile {
    /// The name of the part i.e.
    /// Content-Disposition: form-data; name=<name>;
    let name: String
    /// The name of the file being uploaded (some server implementations care about this)
    /// i.e.Content-Disposition: form-data; name=xxx; filename=<filename>
    let filename: String
    /// The content-type of the file being uploaded i.e.
    /// Content-Type: <mimeType>
    let mimeType: String
    /// The actual data uploaded
    let data: Data
}

protocol HttpRequest {
    
    /// Use if url is different to the base environment URL
    var baseURL: String? { get }
    /// The url path relate to the base url for the request
    var path: String { get }
    /// The http method
    var method: HttpMethod { get }
    /// Query parameters added to the request
    var query: [String: Any]? { get }
    /// Body for the request. Only used in practice for PUT and POST
    var body: [String: Any]? { get }
    /// Multipart formdata (without file uploading)
    var formData: [String: Any]? { get }
    /// Extra headers sent along with the network request
    var headers: [String: Any]? { get }
    /// Any data sent for multipart file uploads
    var file: [HttpMultipartFile]? { get }
    /// Response parser (for custom responses that don't conform to our expected structure)
    var parser: HttpResponseParser? { get }
}

extension HttpRequest {
    var baseURL: String? {
        return nil
    }
    
    var parser: HttpResponseParser? {
        return nil
    }
}

enum HttpMethod: String {
    case post = "POST"
    case put = "PUT"
    case get = "GET"
    case delete = "DELETE"
    case patch = "PATCH"
}
