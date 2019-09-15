//
//  HttpService.swift
//  sharedeal
//
//  Created by Eddie Long on 14/09/2019.
//  Copyright © 2019 Eddie Long. All rights reserved.
//

import Foundation
import RxSwift

enum HttpError: Error {
    case emptydata
    case statusCode(code: Int)
    case invalidContentType(type: String)
    case missingContentType
    case jsonDecodeError(error: Error)
    case connectionError(error: Error)
}

protocol HttpService {
    
    init(environment: Environment)
    
    @discardableResult
    func execute<T: Codable>(request: HttpRequest, completion: @escaping (Result<T, Error>) -> Void) -> Cancellable
    
    // Rx version just wraps the above request
    func execute<T: Codable>(request: HttpRequest) -> Observable<T>
}
