//
//  File.swift
//  
//
//  Created by Rasika Bharati on 29/08/24.
//

import Foundation
import SwiftyJSON
import Alamofire

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
    // Configuration
    private static let maxRetries = 3
    private static let timeoutInterval: TimeInterval = 30
    private static let retryDelay: TimeInterval = 2
    
    static func sendRequest<T: Codable, R: Any>(
        request: ISMChatAPIRequest<R>,
        showLoader: Bool = true,
        retryCount: Int = 0,
        completion: @escaping (_ result: ISMChatResult<T, ISMChatNewAPIError>) -> Void
    ) {
        if showLoader {
            DispatchQueue.main.async {
                // ISMShowLoader.shared.startLoading()
            }
        }
        
        // Configure URL
        var urlComponents = URLComponents(url: request.endPoint.baseURL.appendingPathComponent(request.endPoint.path),
                                        resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = request.endPoint.queryParams?.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        guard let url = urlComponents?.url else {
            handleError(.invalidResponse, showLoader: showLoader, completion: completion)
            return
        }
        
        // Configure URLRequest
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.endPoint.method.rawValue
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("keep-alive", forHTTPHeaderField: "Connection")
        urlRequest.timeoutInterval = timeoutInterval
        
        // Add headers
        request.endPoint.headers?.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        
        // Add body if present
        if let requestBody = request.requestBody as? [String: Any] {
            do {
                let jsonBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
                urlRequest.httpBody = jsonBody
                print("Request Body: \(String(data: jsonBody, encoding: .utf8) ?? "Unable to encode body")")
            } catch {
                handleError(.invalidResponse, showLoader: showLoader, completion: completion)
                return
            }
        }
        
        // Create URLSession configuration
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = timeoutInterval
        configuration.timeoutIntervalForResource = timeoutInterval
        configuration.waitsForConnectivity = true
        
        let session = URLSession(configuration: configuration)
        
        let task = session.dataTask(with: urlRequest) { data, response, error in
            DispatchQueue.main.async {
                // Handle network errors with retry logic
                if let error = error as NSError? {
                    // Network-related errors that warrant a retry
                    let retryableErrors = [-1001, -1003, -1004, -1005, -1009]
                    
                    if retryableErrors.contains(error.code) && retryCount < maxRetries {
                        print("Retrying request (attempt \(retryCount + 1) of \(maxRetries))")
                        
                        DispatchQueue.global().asyncAfter(deadline: .now() + retryDelay) {
                            sendRequest(
                                request: request,
                                showLoader: showLoader,
                                retryCount: retryCount + 1,
                                completion: completion
                            )
                        }
                        return
                    }
                    
                    completion(.failure(.decodingError(error)))
                    if showLoader {
                        // ISMShowLoader.shared.stopLoading()
                    }
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    handleError(.invalidResponse, showLoader: showLoader, completion: completion)
                    return
                }
                
                guard let data = data else {
                    handleError(.invalidResponse, showLoader: showLoader, completion: completion)
                    return
                }
                
                print("Response Status Code: \(httpResponse.statusCode)")
                print(JSON(data))
                
                switch httpResponse.statusCode {
                case 200, 201:
                    do {
                        let decoder = JSONDecoder()
                        let responseObject = try decoder.decode(T.self, from: data)
                        completion(.success(responseObject, nil))
                    } catch {
                        print("Decoding Error: \(error)")
                        completion(.failure(.decodingError(error)))
                    }
                case 404:
                    completion(.failure(.httpError(httpResponse.statusCode)))
                case 401, 406:
                    // Handle refresh token
                    handleTokenRefresh(request: request, completion: completion)
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
    
    private static func handleError<T: Codable>(
        _ error: ISMChatNewAPIError,
        showLoader: Bool,
        completion: @escaping (ISMChatResult<T, ISMChatNewAPIError>) -> Void
    ) {
        DispatchQueue.main.async {
            completion(.failure(error))
            if showLoader {
                // ISMShowLoader.shared.stopLoading()
            }
        }
    }
    
    private static func handleTokenRefresh<T: Codable, R: Any>(
        request: ISMChatAPIRequest<R>,
        completion: @escaping (ISMChatResult<T, ISMChatNewAPIError>) -> Void
    ) {
        // Implement token refresh logic here
        // After successful refresh, retry the original request
        // For now, just return an error
        completion(.failure(.httpError(401)))
    }
}

// struct ISMChatNewAPIManager {
//     
//     static func sendRequest<T: Codable, R: Any>(request: ISMChatAPIRequest<R>, showLoader: Bool = true, completion: @escaping (_ result: ISMChatResult<T, ISMChatNewAPIError>) -> Void) {
//         
//         if showLoader {
//             DispatchQueue.main.async {
//                 // ISMShowLoader.shared.startLoading()
//             }
//         }
//         
//         var urlComponents = URLComponents(url: request.endPoint.baseURL.appendingPathComponent(request.endPoint.path), resolvingAgainstBaseURL: true)
//         urlComponents?.queryItems = request.endPoint.queryParams?.map { URLQueryItem(name: $0.key, value: $0.value) }
//         
//         guard let url = urlComponents?.url else {
//             DispatchQueue.main.async {
//                 completion(.failure(.invalidResponse))
//                 // ISMShowLoader.shared.stopLoading()
//             }
//             return
//         }
//         print(url)
//         var urlRequest = URLRequest(url: url)
//         urlRequest.httpMethod = request.endPoint.method.rawValue
//         urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
//         urlRequest.setValue("keep-alive", forHTTPHeaderField: "Connection")
//         urlRequest.timeoutInterval = 60
//         
//         // Set headers if provided
//         request.endPoint.headers?.forEach { key, value in
//             urlRequest.setValue(value, forHTTPHeaderField: key)
//         }
//         
//         if let requestBody = request.requestBody as? [String: Any] {
//             do {
//                 // Serialize dictionary to JSON data
//                 let jsonBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
//                 urlRequest.httpBody = jsonBody
//                 // Optionally, log the JSON body to ensure it's correct
//                 print("Request Body: \(String(data: jsonBody, encoding: .utf8) ?? "Unable to encode body")")
//             } catch {
//                 DispatchQueue.main.async {
//                     completion(.failure(.invalidResponse))
//                     // ISMShowLoader.shared.stopLoading()
//                 }
//                 return
//             }
//         }
//         
//         let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
//             DispatchQueue.main.async {
//                 guard let httpResponse = response as? HTTPURLResponse else {
//                     completion(.failure(.invalidResponse))
//                     // ISMShowLoader.shared.stopLoading()
//                     return
//                 }
//                 
//                 if let error = error {
//                     completion(.failure(.decodingError(error)))
//                     return
//                 }
//                 
//                 guard let data = data else {
//                     completion(.failure(.invalidResponse))
//                     return
//                 }
//                 
//                 print(JSON(data))
//                 
//                 switch httpResponse.statusCode {
//                 case 200,201:
//                     do {
//                         let responseObject = try JSONDecoder().decode(T.self, from: data)
//                         completion(.success(responseObject, nil))
//                     } catch {
//                         completion(.failure(.decodingError(error)))
//                     }
//                 case 404:
//                     completion(.failure(.httpError(httpResponse.statusCode)))
//                 case 401, 406:
//                     // Handle the refresh token here.
//                     break
//                 default:
//                     completion(.failure(.httpError(httpResponse.statusCode)))
//                 }
//                 
//                 if showLoader {
//                     // ISMShowLoader.shared.stopLoading()
//                 }
//             }
//         }
//         
//         task.resume()
//     }
// }
     
//     static func sendRequest<T: Codable, R: Any>(request: ISMChatAPIRequest<R>, showLoader: Bool = true, completion: @escaping (_ result: ISMChatResult<T, ISMChatNewAPIError>) -> Void) {
//
//         if showLoader {
//             DispatchQueue.main.async {
//                 // ISMShowLoader.shared.startLoading()
//             }
//         }
//
//         // Construct the URL
//         var urlComponents = URLComponents(url: request.endPoint.baseURL.appendingPathComponent(request.endPoint.path), resolvingAgainstBaseURL: true)
//         urlComponents?.queryItems = request.endPoint.queryParams?.map { URLQueryItem(name: $0.key, value: $0.value) }
//
//         guard let url = urlComponents?.url else {
//             DispatchQueue.main.async {
//                 completion(.failure(.invalidResponse))
//                 // ISMShowLoader.shared.stopLoading()
//             }
//             return
//         }
//         print("Request URL: \(url)")
//
//         // Setup headers
//         var headers: HTTPHeaders = [
//             "Content-Type": "application/json",
//             "Connection": "close" // Using 'close' to avoid keep-alive issues
//         ]
//         if let customHeaders = request.endPoint.headers {
//             customHeaders.forEach { key, value in
//                 headers.add(name: key, value: value)
//             }
//         }
//
//         // Setup request body if provided
//         var parameters: [String: Any]? = nil
//         if let requestBody = request.requestBody as? [String: Any] {
//             parameters = requestBody
//             print("Request Body: \(requestBody)")
//         }
//
//         // Alamofire request
//         
//         AF.request(url, method: HTTPMethod(rawValue: request.endPoint.method.rawValue), parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseDecodable { (response: DataResponse<T, AFError>) in
//             do {
//                 if let jsonData = try JSONSerialization.jsonObject(with: response.data ?? Data(), options: .mutableContainers) as? NSDictionary{
//                     ISMChatHelper.print("JSON DATA:",jsonData)
//                 }
//             } catch let error {
//                 ISMChatHelper.print("error json serialization :",error)
//             }
//             guard let statusCode = response.response?.statusCode,let data = response.data else{
//                 return completion(.failure(.none))
//             }
//             switch ISMChat_HTTPStatusCode.init(rawValue: statusCode){
//             case .Success,.Created:
//
//                 do{
//                     let model = try JSONDecoder().decode(T.self, from:data )
//                     completion(.success(model, nil))
//                 }catch let error{
//                     ISMChatHelper.print(error)
//                     let errorData = ISMChat_ErrorData.init(message: error.localizedDescription, error: "Error")
//                     completion(.failure(.none))
//                 }
//             case .UnprocessableEntity :
////                 if handleUnprocessableEntity {
////                     do{
////                         let model = try JSONDecoder().decode(T.self, from:data )
////                         completion(.success(model))
////                     }catch let error{
////                         ISMChatHelper.print("\(error.localizedDescription)")
////                         let errorData = ISMChat_ErrorData.init(message: error.localizedDescription, error: "Error")
////                         completion(.failure(errorData))
////                     }
////                 }else{
//                     do{
//                         let errorData = try JSONDecoder().decode(ISMChat_ErrorData.self, from:data )
//                         completion(.failure(.none))
//                     }catch let error{
//                         let errorData = ISMChat_ErrorData.init(message: error.localizedDescription, error: "Error")
//                         completion(.failure(.none))
//                     }
////                 }
//             default :
//                 do{
//                     let errorData = try JSONDecoder().decode(ISMChat_ErrorData.self, from:data )
//                     completion(.failure(.none))
//                 }catch let error{
//                     let errorData = ISMChat_ErrorData.init(message: error.localizedDescription, error: "Error")
//                     completion(.failure(.none))
//                 }
//             }
// //            if isShowLoader{
// //                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()){
// //                    ISMChat_Helper.hideLoader()
// //                }
// //
// //            }
//         }
//         
//
//             
//     }
//     static func sendRequest<T: Codable, R: Any>(request: ISMChatAPIRequest<R>, showLoader: Bool = true, completion: @escaping (_ result: ISMChatResult<T, ISMChatNewAPIError>) -> Void) {

//         if showLoader {
//             DispatchQueue.main.async {
//                 // ISMShowLoader.shared.startLoading()
//             }
//         }
//
//         var urlComponents = URLComponents(url: request.endPoint.baseURL.appendingPathComponent(request.endPoint.path), resolvingAgainstBaseURL: true)
//         urlComponents?.queryItems = request.endPoint.queryParams?.map { URLQueryItem(name: $0.key, value: $0.value) }
//
//         guard let url = urlComponents?.url else {
//             DispatchQueue.main.async {
//                 completion(.failure(.invalidResponse))
//                 // ISMShowLoader.shared.stopLoading()
//             }
//             return
//         }
//         print(url)
//         var urlRequest = URLRequest(url: url)
//         urlRequest.httpMethod = request.endPoint.method.rawValue
//         urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
//         urlRequest.setValue("close", forHTTPHeaderField: "Connection") // Use "close" to avoid keep-alive issues
//         urlRequest.timeoutInterval = 60 // Increased timeout interval to 60 seconds
//
//         // Set headers if provided
//         request.endPoint.headers?.forEach { key, value in
//             urlRequest.setValue(value, forHTTPHeaderField: key)
//         }
//
//         if let requestBody = request.requestBody as? [String: Any] {
//             do {
//                 let jsonBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
//                 urlRequest.httpBody = jsonBody
//                 print("Request Body: \(String(data: jsonBody, encoding: .utf8) ?? "Unable to encode body")")
//             } catch {
//                 DispatchQueue.main.async {
//                     completion(.failure(.invalidResponse))
//                     // ISMShowLoader.shared.stopLoading()
//                 }
//                 return
//             }
//         }
//
//         let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
//             DispatchQueue.main.async {
//                 if let error = error as NSError? {
//                     if error.code == NSURLErrorNetworkConnectionLost {
//                         completion(.failure(.networkConnectionLost)) // Handle network lost error
//                     } else {
//                         completion(.failure(.decodingError(error)))
//                     }
//                     // ISMShowLoader.shared.stopLoading()
//                     return
//                 }
//
//                 guard let httpResponse = response as? HTTPURLResponse else {
//                     completion(.failure(.invalidResponse))
//                     // ISMShowLoader.shared.stopLoading()
//                     return
//                 }
//
//                 guard let data = data else {
//                     completion(.failure(.invalidResponse))
//                     return
//                 }
//
//                 print(JSON(data))
//
//                 switch httpResponse.statusCode {
//                 case 200, 201:
//                     do {
//                         let responseObject = try JSONDecoder().decode(T.self, from: data)
//                         completion(.success(responseObject, nil))
//                     } catch {
//                         completion(.failure(.decodingError(error)))
//                     }
//                 case 404:
//                     completion(.failure(.httpError(httpResponse.statusCode)))
//                 case 401, 406:
//                     // Handle refresh token here
//                     break
//                 default:
//                     completion(.failure(.httpError(httpResponse.statusCode)))
//                 }
//
//                 if showLoader {
//                     // ISMShowLoader.shared.stopLoading()
//                 }
//             }
//         }
//
//         task.resume()
//     }

 
//}


public enum ISMChatNewAPIError: Error {
    case networkError(Error)
    case invalidResponse
    case decodingError(Error)
    case networkConnectionLost
    case httpError(Int)
}

enum ISMChat_HTTPStatusCode: Int {
    case Success = 200
    case Created = 201
    case BadRequest = 400
    case Unauthorized = 401
    case UnprocessableEntity = 422
    case None
}

public struct ISMChat_ErrorData: Codable , Error{
    let status : Int?
    let statusCode : Int?
    var error : String?
    var message : String?
    var errorCode: Int?
    init(message:String?,error:String?) {
        self.status = nil
        self.statusCode = nil
        self.message = message
        self.error = error
    }
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        status = try? container.decode(Int.self, forKey: .status)
        statusCode = try? container.decode(Int.self, forKey: .status)
        error = try? container.decode(String.self, forKey: .error)
        message = try? container.decode(String.self, forKey: .message)
        errorCode = try? container.decode(Int.self, forKey: .errorCode)
    }
}

public struct ISMChatErrorMessage : Codable{
    public  let error : String?
    public  let errorCode : Int?
}

public enum ISMChatResult<T,ErrorData>{
    case success(T,Data?)
    case failure(ErrorData?)
}

