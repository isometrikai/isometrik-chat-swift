//
//  File.swift
//  
//
//  Created by Rasika Bharati on 29/08/24.
//

import Foundation
import SwiftyJSON

enum ISMChatHTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

struct ISMChatAPIError: Error {
    let message: String
}


protocol ISMChatURLConvertible{
    
    var baseURL : URL{
        get
    }
    var path : String{
        get
    }
    var method : ISMChatHTTPMethod{
        get
    }
    var queryParams : [String: String]?{
        get
    }
    var headers :[String: String]? {
        get
    }

    
}


extension ISMChatURLConvertible {
    func makeRequest() -> URLRequest? {
        var urlComponents = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = queryParams?.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        guard let url = urlComponents?.url else {
            return nil
        }
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // Set headers if provided
          headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        
        return request
    }
}



struct ISMChatAPIRequest<R> {
    let endPoint : ISMChatURLConvertible
    let requestBody: R?
}


struct ISMChatNewAPIManager {
    
    static func sendRequest<T: Codable, R: Any>(request: ISMChatAPIRequest<R>, showLoader: Bool = true, completion: @escaping (_ result: ISMChatResult<T, ISMChatNewAPIError>) -> Void) {
        
        if showLoader {
            DispatchQueue.main.async {
                // ISMShowLoader.shared.startLoading()
            }
        }
        
        var urlComponents = URLComponents(url: request.endPoint.baseURL.appendingPathComponent(request.endPoint.path), resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = request.endPoint.queryParams?.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        guard let url = urlComponents?.url else {
            DispatchQueue.main.async {
                completion(.failure(.invalidResponse))
                // ISMShowLoader.shared.stopLoading()
            }
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.endPoint.method.rawValue
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Set headers if provided
        request.endPoint.headers?.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        
        if let requestBody = request.requestBody as? Codable {
            do {
                let jsonBody = try JSONEncoder().encode(requestBody)
                urlRequest.httpBody = jsonBody
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.invalidResponse))
                    // ISMShowLoader.shared.stopLoading()
                }
                return
            }
        }
        
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            DispatchQueue.main.async {
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(.invalidResponse))
                    // ISMShowLoader.shared.stopLoading()
                    return
                }
                
                if let error = error {
                    completion(.failure(.decodingError(error)))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(.invalidResponse))
                    return
                }
                
                print(JSON(data))
                
                switch httpResponse.statusCode {
                case 200:
                    do {
                        let responseObject = try JSONDecoder().decode(T.self, from: data)
                        completion(.success(responseObject, nil))
                    } catch {
                        completion(.failure(.decodingError(error)))
                    }
                case 404:
                    completion(.failure(.httpError(httpResponse.statusCode)))
                case 401, 406:
                    // Handle the refresh token here.
                    break
                default:
                    completion(.failure(.httpError(httpResponse.statusCode)))
                }
                
                if showLoader {
                    // ISMShowLoader.shared.stopLoading()
                }
            }
        }
        
        task.resume()
    }
}


public enum ISMChatNewAPIError: Error {
    case networkError(Error)
    case invalidResponse
    case decodingError(Error)
    case httpError(Int)
}


public struct ISMChatErrorMessage : Codable{
    public  let error : String?
    public  let errorCode : Int?
}

public enum ISMChatResult<T,ErrorData>{
    case success(T,Data?)
    case failure(ErrorData)
}

