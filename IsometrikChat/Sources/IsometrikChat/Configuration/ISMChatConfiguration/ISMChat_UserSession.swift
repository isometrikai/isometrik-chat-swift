//
//  UserSession.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 17/11/23.
//

import Foundation


class ISMChat_UserSession: NSObject {

    public static var shared = ISMChat_UserSession()
    
    // MARK: - SETTERS
    
    public func setUserId(userId: String){
        UserDefaults.standard.set(userId, forKey: ISMChat_AppConstants.userDefaultUserId)
    }
    
    public func setUserToken(token : String){
        UserDefaults.standard.set(token, forKey: ISMChat_AppConstants.userDefaultUserToken)
    }
    
    public func setUserEmailId(email : String){
        UserDefaults.standard.set(email, forKey: ISMChat_AppConstants.userDefaultUserEmailId)
    }
    
    public func setUserName(userName : String){
        UserDefaults.standard.set(userName, forKey: ISMChat_AppConstants.userDefaultUserName)
    }
    
    public func setUserProfilePicture(url : String){
        UserDefaults.standard.set(url, forKey: ISMChat_AppConstants.userDefaultUserProfileImage)
    }
    
    public func setnotification(on : Bool){
        UserDefaults.standard.set(on, forKey: ISMChat_AppConstants.userDefaultKeepNotificationOn)
    }
    
    public func setUserBio(bio : String){
        UserDefaults.standard.set(bio, forKey: ISMChat_AppConstants.userDefaultUserBio)
    }
    
    
    public func setLastSeen(showLastSeen : Bool){
        UserDefaults.standard.set(showLastSeen, forKey: ISMChat_AppConstants.userDefaultLastSeen)
    }
    
    
    // MARK: - GETTERS
    
    public func getUserId() -> String {
        guard let userId = UserDefaults.standard.string(forKey: ISMChat_AppConstants.userDefaultUserId) else { return "" }
        return userId
    }
    
    public func getUserToken() -> String {
        guard let userToken = UserDefaults.standard.string(forKey: ISMChat_AppConstants.userDefaultUserToken) else { return ""}
        return userToken
    }
    
    public func getEmailId() -> String {
        guard let email = UserDefaults.standard.string(forKey: ISMChat_AppConstants.userDefaultUserEmailId) else { return ""}
        return email
    }
    
    public func getUserName() -> String {
        guard let userName = UserDefaults.standard.string(forKey: ISMChat_AppConstants.userDefaultUserName) else { return ""}
        return userName
    }
    
    public func getUserProfilePicture() -> String {
        guard let url = UserDefaults.standard.string(forKey: ISMChat_AppConstants.userDefaultUserProfileImage) else { return ""}
        return url
    }
    
    public func getUserBio() -> String {
        guard let url = UserDefaults.standard.string(forKey: ISMChat_AppConstants.userDefaultUserBio) else { return ""}
        return url
    }
    
    public func getNotificationStatus() -> Bool {
        return UserDefaults.standard.bool(forKey: ISMChat_AppConstants.userDefaultKeepNotificationOn)
    }
    
    public func getLastSeenStatus() -> Bool {
        return UserDefaults.standard.bool(forKey: ISMChat_AppConstants.userDefaultLastSeen)
    }
    
    
    // MARK: - DEFAULTS
    
    public func clearUserSession(){
        UserDefaults.standard.removeObject(forKey: ISMChat_AppConstants.userDefaultUserId)
        UserDefaults.standard.removeObject(forKey: ISMChat_AppConstants.userDefaultUserToken)
        UserDefaults.standard.removeObject(forKey: ISMChat_AppConstants.userDefaultUserEmailId)
        UserDefaults.standard.removeObject(forKey: ISMChat_AppConstants.userDefaultUserName)
        UserDefaults.standard.removeObject(forKey: ISMChat_AppConstants.userDefaultUserProfileImage)
        UserDefaults.standard.removeObject(forKey: ISMChat_AppConstants.userDefaultKeepNotificationOn)
        UserDefaults.standard.removeObject(forKey: ISMChat_AppConstants.userDefaultUserBio)
        UserDefaults.standard.removeObject(forKey: ISMChat_AppConstants.userDefaultLastSeen)
    }
}

struct ISMChat_AppConstants {
    static let userDefaultUserToken = "ismChatSdkUserToken"
    static let userDefaultUserEmailId = "ismChatSdkUserEmail"
    static let userDefaultUserId = "ismChatSdkUserId"
    static let userDefaultUserName = "ismChatSdkUserName"
    static let userDefaultUserProfileImage = "ismChatSdkUserProfileImage"
    static let userDefaultKeepNotificationOn = "ismChatSdkNotification"
    static let userDefaultUserBio = "ismChatSdkUserBio"
    static let userDefaultLastSeen = "ismChatsdkLastSeen"
}

