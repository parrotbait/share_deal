//
//  MockHttpService.swift
//  sharedealTests
//
//  Created by Eddie Long on 15/09/2019.
//  Copyright © 2019 Eddie Long. All rights reserved.
//

import Foundation
import RxSwift

@testable import sharedeal

class HttpCancellable: Cancellable {
    func cancel() {}
}

final class MockHttpService: HttpService {
    enum TestError: Error { case none }
    
    init(environment: Environment) {}
    
    @discardableResult
    func execute<T: Codable>(request: HttpRequest, completion: @escaping (Result<T, Error>) -> Void) -> Cancellable {
        // No networking will happen
        completion(.failure(TestError.none))
        return HttpCancellable()
    }
    
    func execute<T: Codable>(request: HttpRequest) -> Observable<T> {
        // No networking will happen
        return Observable.error(TestError.none)
    }
}
