//
//  NetworkService.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 27/01/23.
//

import Foundation
import Alamofire
import UIKit

public struct ISMChat_NetworkServices{
    public struct Urls{
        public struct BaseUrl{
            static let baseUrl : String = {
                guard
                    let API_ENDPOINT = Bundle.main.object(forInfoDictionaryKey: "API_ENDPOINT") as? String
                else {
                    fatalError("Info.plist contains malformed (or missing) API_ENDPOINT for this configuration.")
                }
                return API_ENDPOINT
            }()
        }
        static public let guestToken                    = BaseUrl.baseUrl + "/chat/user/authenticate"
        static public let register                      = BaseUrl.baseUrl + "/chat/user"
        static public let chatList                      = BaseUrl.baseUrl + "/chat/conversations"
        static public let messages                      = BaseUrl.baseUrl + "/chat/messages"
        static public let userDetail                    = BaseUrl.baseUrl + "/chat/user/details"
        static public let sendMessage                   = BaseUrl.baseUrl + "/chat/message"
        static public let deleteConversationLocal       = BaseUrl.baseUrl + "/chat/conversation/local"//Delete User
        static public let presignedUrl                  = BaseUrl.baseUrl + "/chat/messages/presignedurls"
        static public let conversationDetail            = BaseUrl.baseUrl + "/chat/conversation/details/"
        static public let messageRead                   = BaseUrl.baseUrl + "/chat/message/status/read"
        static public let messageDelivered              = BaseUrl.baseUrl + "/chat/message/status/delivery"
        static public let messageDeleteForMe            = BaseUrl.baseUrl + "/chat/messages/self"
        static public let messageDeleteForEveryone      = BaseUrl.baseUrl + "/chat/messages/everyone"
        static public let forwardMessage                = BaseUrl.baseUrl + "/chat/message/forward"
        static public let getMessagesInConersation      = BaseUrl.baseUrl + "/chat/messages/user"
        static public let getUsers                      = BaseUrl.baseUrl + "/chat/users"
        static public let createConversation            = BaseUrl.baseUrl + "/chat/conversation"
        static public let preassignedUrlCreate          = BaseUrl.baseUrl + "/chat/user/presignedurl/create"
        static public let preassignedUrlUpdate          = BaseUrl.baseUrl + "/chat/user/presignedurl/update"
        static public let markMessageAsRead             = BaseUrl.baseUrl + "/chat/messages/read"
        static public let readMessageIndicator          = BaseUrl.baseUrl + "/chat/indicator/read"
        static public let deliveredMessageIndicator     = BaseUrl.baseUrl + "/chat/indicator/delivered"
        static public let typingMessageIndicator        = BaseUrl.baseUrl + "/chat/indicator/typing"
        static public let clearChat                     = BaseUrl.baseUrl + "/chat/conversation/clear"//Clear Chat
        static public let getBlockUser                  = BaseUrl.baseUrl + "/chat/user/block"
        static public let blockUsers                    = BaseUrl.baseUrl + "/chat/user/block"
        static public let unBlockUsers                  = BaseUrl.baseUrl + "/chat/user/unblock"
        static public let getnonBlockUsers              = BaseUrl.baseUrl + "/chat/user/nonblock"
        static public let groupMembers                  = BaseUrl.baseUrl + "/chat/conversation/members"
        static public let eligibleUsers                 = BaseUrl.baseUrl + "/chat/conversation/eligible/members"
        static public let exitGroup                     = BaseUrl.baseUrl + "/chat/conversation/leave"
        static public let groupAdmin                    = BaseUrl.baseUrl + "/chat/conversation/admin"
        static public let groupTitle                    = BaseUrl.baseUrl + "/chat/conversation/title"
        static public let groupImage                    = BaseUrl.baseUrl + "/chat/conversation/image"
        static public let conversationSetting           = BaseUrl.baseUrl + "/chat/conversation/settings"
        static public let emojiReaction                 = BaseUrl.baseUrl + "/chat/reaction"
        //broadCast Flow
        static public let createBroadCast               = BaseUrl.baseUrl + "/chat/groupcast"
        static public let getBroadCast                  = BaseUrl.baseUrl + "/chat/groupcasts"
        static public let getBroadCastMembers           = BaseUrl.baseUrl + "/chat/groupcast/members"
        static public let postbroadCastMessage          = BaseUrl.baseUrl + "/chat/groupcast/message"
        static public let getbroadCastMessage           = BaseUrl.baseUrl + "/chat/groupcast/messages"
        static public let broadcastmessageDeleteForMe   = BaseUrl.baseUrl + "/chat/groupcast/message/self"
        static public let broadcastmessageDeleteForEveryone      = BaseUrl.baseUrl + "/chat/groupcast/message/everyone"
        static public let addmembersToBroadCast         = BaseUrl.baseUrl + "/chat/groupcast/members"
        static public let eligibleuserForGroupcast      = BaseUrl.baseUrl + "/chat/groupcast/eligible/members"
        static public let groupcastMessageDelivered     = BaseUrl.baseUrl + "/chat/groupcast/message/status/delivery"
        static public let groupcastMessageRead          = BaseUrl.baseUrl + "/chat/groupcast/message/status/read"
    }
    
    struct ParameterConstants {
        static let licenseKey                   = "licenseKey"
        static let appSecret                    = "appSecret"
        static let userSecret                   = "userSecret"
        static let body                         = "body"
    }
}


public class ISMChat_APIManager{
    
    public var configuration : ISMChat_ProjectConfig?
    
    init(configuration: ISMChat_ProjectConfig) {
        self.configuration = configuration
    }

    public func requestService<T:Codable>(serviceUrl:String,httpMethod :HTTPMethod,params:[String:Any]? = nil,isShowLoader:Bool = true, handleUnprocessableEntity : Bool = false, checkCheckinStatus : Bool = false,  completion: @escaping (_ response : ISMChat_Response<T?,ISMChat_ErrorData?>)->()) {
        // Note : UnprocessableEntity is 422 which needs to handle for profile info status. we can change the logic later
        guard let path = serviceUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)else
        {return}
//        if isShowLoader{
//            ISMChat_Helper.addLoader()
//        }
        
        let headers = configuration?.headers
        
        ISMChat_Helper.print("PATH  :",path)
         
      
        AF.request(path, method: httpMethod, parameters: params, encoding: JSONEncoding.default, headers: headers).responseDecodable { (response: DataResponse<T, AFError>) in
            do {
                if let jsonData = try JSONSerialization.jsonObject(with: response.data ?? Data(), options: .mutableContainers) as? NSDictionary{
                    ISMChat_Helper.print("JSON DATA:",jsonData)
                }
            } catch let error {
                ISMChat_Helper.print("error json serialization :",error)
            }
            guard let statusCode = response.response?.statusCode,let data = response.data else{
                return completion(.failure(nil))
            }
            switch ISMChat_HTTPStatusCode.init(rawValue: statusCode){
            case .Success,.Created:

                do{
                    let model = try JSONDecoder().decode(T.self, from:data )
                    completion(.success(model))
                }catch let error{
                    ISMChat_Helper.print(error)
                    let errorData = ISMChat_ErrorData.init(message: error.localizedDescription, error: "Error")
                    completion(.failure(errorData))
                }
            case .UnprocessableEntity :
                if handleUnprocessableEntity {
                    do{
                        let model = try JSONDecoder().decode(T.self, from:data )
                        completion(.success(model))
                    }catch let error{
                        ISMChat_Helper.print("\(error.localizedDescription)")
                        let errorData = ISMChat_ErrorData.init(message: error.localizedDescription, error: "Error")
                        completion(.failure(errorData))
                    }
                }else{
                    do{
                        let errorData = try JSONDecoder().decode(ISMChat_ErrorData.self, from:data )
                        completion(.failure(errorData))
                    }catch let error{
                        let errorData = ISMChat_ErrorData.init(message: error.localizedDescription, error: "Error")
                        completion(.failure(errorData))
                    }
                }
            default :
                do{
                    let errorData = try JSONDecoder().decode(ISMChat_ErrorData.self, from:data )
                    completion(.failure(errorData))
                }catch let error{
                    let errorData = ISMChat_ErrorData.init(message: error.localizedDescription, error: "Error")
                    completion(.failure(errorData))
                }
            }
//            if isShowLoader{
//                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()){
//                    ISMChat_Helper.hideLoader()
//                }
//
//            }
        }
    }
}

struct ImageUplaod:Codable{
   var url : String
}

public struct ISMChat_ErrorData: Codable , Error{
    public let status : Int?
    public let statusCode : Int?
    public var error : String?
    public var message : String?
    public var errorCode: Int?
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

public enum ISMChat_Response<T,ISMChat_ErrorData>{
    case success(T)
    case failure(ISMChat_ErrorData)
}

enum ISMChat_HTTPStatusCode: Int {
    case Success = 200
    case Created = 201
    case BadRequest = 400
    case Unauthorized = 401
    case UnprocessableEntity = 422
    case None
}
