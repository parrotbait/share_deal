//
//  ParserTests.swift
//  sharedealTests
//
//  Created by Eddie Long on 15/09/2019.
//  Copyright © 2019 Eddie Long. All rights reserved.
//

import Foundation

import XCTest
import RxBlocking
import RxSwift

@testable import sharedeal

class ParserTests: XCTestCase {

    func testInvalidContentTypeJSONParser() {
        let parser = DefaultHttpJsonResponseParser()
        let text = "{}"
        let res: Result<String, Error> = parser.parse(data: text.data(using: .utf8)!, headers: ["content-type": "image/jpeg"])
        switch res {
        case .success:
            XCTFail("Expected parsing to fail")
        case .failure(let error):
            let httpError = error as! HttpError
            if case .invalidContentType = httpError {
            } else {
                XCTFail("Expected invalid content type failure")
            }
        }
    }
    
    func testMissingContentTypeJSONParser() {
        let parser = DefaultHttpJsonResponseParser()
        let text = "{}"
        let res: Result<String, Error> = parser.parse(data: text.data(using: .utf8)!, headers: [:])
        switch res {
        case .success:
            XCTFail("Expected parsing to fail")
        case .failure(let error):
            let httpError = error as! HttpError
            if case .missingContentType = httpError {
            } else {
                XCTFail("Expected invalid content type failure")
            }
        }
    }
    
    func testMissingContentTypeTextPlainParser() {
        let parser = DefaultHttpPlaintextResponseParser()
        let text = "{}"
        let res: Result<String, Error> = parser.parse(data: text.data(using: .utf8)!, headers: [:])
        switch res {
        case .success:
            XCTFail("Expected parsing to fail")
        case .failure(let error):
            let httpError = error as! HttpError
            if case .missingContentType = httpError {
            } else {
                XCTFail("Expected invalid content type failure")
            }
        }
    }
    
    func testInvalidContentTypeTextPlainParser() {
        let parser = DefaultHttpPlaintextResponseParser()
        let text = "{}"
        let res: Result<String, Error> = parser.parse(data: text.data(using: .utf8)!, headers: ["content-type": "image/jpeg"])
        switch res {
        case .success:
            XCTFail("Expected parsing to fail")
        case .failure(let error):
            let httpError = error as! HttpError
            if case .invalidContentType = httpError {
            } else {
                XCTFail("Expected invalid content type failure")
            }
            
        }
    }
    
    // TODO: Add tests for testing it valid resposes
}
