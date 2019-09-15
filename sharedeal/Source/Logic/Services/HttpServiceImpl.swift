//
//  HttpServiceImpl.swift
//  sharedeal
//
//  Created by Eddie Long on 14/09/2019.
//  Copyright © 2019 Eddie Long. All rights reserved.
//

import Foundation
import RxSwift

typealias HttpCompletion<T> = (Result<T, Error>) -> Void  where T : Decodable, T : Encodable
private enum HttpServiceError: Error {
    case preparingURLRequestError
}

final class HttpCancellable: Cancellable {
    var task: URLSessionTask?
    init (task: URLSessionTask) {
        self.task = task
    }
    
    func cancel() {
        task?.cancel()
        task = nil
    }
    
}

final class HttpServiceImpl: HttpService {
    private let environment: Environment
    lazy private var session: URLSession = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
    
    init(environment: Environment) {
        self.environment = environment
    }
    
    var baseUrl: String {
        return environment.host
    }
}

extension HttpServiceImpl {
    
    func execute<T>(request: HttpRequest, completion: @escaping HttpCompletion<T>) -> Cancellable where T : Decodable, T : Encodable {
        guard let rq = try? self.prepareURLRequest(for: request) else {
            fatalError("Invalid url request \(request.path)" )
        }
        
        let dataTask = session.dataTask(with: rq, completionHandler: { (data, urlResponse, error) in
            if let error = error {
                return completion(.failure(HttpError.connectionError(error: error)))
            }
            
            guard let data = data else {
                return completion(.failure(HttpError.emptydata))
            }
            
            let response = urlResponse as! HTTPURLResponse
            let statusCode = (urlResponse as! HTTPURLResponse).statusCode
            
            // If the status code is invalid then we bail out here
            switch statusCode {
            case 1 ... 299:
                break
            case 400...:
                return completion(.failure(HttpError.statusCode(code:statusCode)))
            default:
                break
            }
            
            let parser = request.parser ?? DefaultHttpJsonResponseParser()
            return completion(parser.parse(data: data, headers: response.allHeaderFields))
        })
        dataTask.resume()
        return HttpCancellable(task: dataTask)
    }
    
    // MARK: - Private
    private func prepareURLRequest(for request: HttpRequest) throws -> URLRequest {
        // Use environment base url if the request doesn't overwrite
        let base = request.baseURL ?? baseUrl
        let fullUrl = "\(base)\(request.path)"
        var urlRequest = URLRequest(url: URL(string: fullUrl)!)
        
        if let query = request.query {
            var queryItems = [URLQueryItem]()
            
            for queryItem in query {
                if let queryStr = queryItem.value as? String {
                    queryItems.append(URLQueryItem(name: queryItem.key, value: queryStr))
                } else if let queryStrArray = queryItem.value as? [String], !queryStrArray.isEmpty {
                    for queryStrItem in queryStrArray {
                        queryItems.append(URLQueryItem(name: queryItem.key, value: queryStrItem))
                    }
                } else {
                    throw HttpServiceError.preparingURLRequestError
                }
            }
            
            guard var components = URLComponents(string: fullUrl) else {
                throw HttpServiceError.preparingURLRequestError
            }
            
            components.queryItems = queryItems
            urlRequest.url = components.url
        }

        if let body = request.body {
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        }
        
        if request.formData != nil || request.file != nil {
            let boundary = generateBoundary()
            urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            let dataBody = generateBody(withRequest: request, boundary: boundary)
            urlRequest.httpBody = dataBody
        }
        
        request.headers?.forEach { urlRequest.addValue($0.value as! String, forHTTPHeaderField: $0.key) }
        urlRequest.httpMethod = request.method.rawValue
        
        return urlRequest
    }
    
    private func generateBody(withRequest request: HttpRequest, boundary: String) -> Data {
        let lineBreak = "\r\n"
        var body = Data()
        
        if let parameters = request.formData {
            for (key, value) in parameters {
                body.append("--\(boundary  + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)")
                body.append("\(String(describing: value) + lineBreak)")
            }
        }
        
        if let media = request.file {
            for part in media {
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(part.name)\"; filename=\"\(part.filename)\"\(lineBreak)")
                body.append("Content-Type: \(part.mimeType + lineBreak + lineBreak)")
                body.append(part.data)
                body.append(lineBreak)
            }
        }
        
        body.append("--\(boundary)--\(lineBreak)")
        return body
    }
    
    private func generateBoundary() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
}

extension HttpServiceImpl {
    func execute<T: Codable>(request: HttpRequest) -> Observable<T> {
        return Observable.create({ [weak self] (observer) in
            let cancellable = self?.execute(request: request, completion: { (result: Result<T, Error>) in
                switch result {
                case .success(let data):
                    observer.onNext(data)
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            })
            return Disposables.create {
                cancellable?.cancel()
            }
        })
    }
}
