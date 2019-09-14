//
//  HttpError.swift
//  sharedeal
//
//  Created by Eddie Long on 14/09/2019.
//  Copyright © 2019 Eddie Long. All rights reserved.
//

import Foundation

extension HttpError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .emptydata:
            return R.string.localizable.error_http_empty()
        case .connectionError(let error):
            return R.string.localizable.error_http_connection_error(error.localizedDescription)
        case .invalidContentType(let type):
            return R.string.localizable.error_http_bad_content_type(type)
        case .jsonDecodeError(let error):
            return R.string.localizable.error_http_json_decode_error(error.localizedDescription)
        case .statusCode(let code):
            return R.string.localizable.error_http_bad_status_code(code)
        }
    }
}
