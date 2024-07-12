//
//  UserSession.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 17/11/23.
//

import Foundation


public class ISMChatUserSession: NSObject {

    public static var shared = ISMChatUserSession()
    
    // MARK: - SETTERS
    
    public func setUserId(userId: String){
        UserDefaults.standard.set(userId, forKey: ISMChatAppConstants.userDefaultUserId)
    }
    
    public func setUserToken(token : String){
        UserDefaults.standard.set(token, forKey: ISMChatAppConstants.userDefaultUserToken)
    }
    
    public func setUserEmailId(email : String){
        UserDefaults.standard.set(email, forKey: ISMChatAppConstants.userDefaultUserEmailId)
    }
    
    public func setUserName(userName : String){
        UserDefaults.standard.set(userName, forKey: ISMChatAppConstants.userDefaultUserName)
    }
    
    public func setUserProfilePicture(url : String){
        UserDefaults.standard.set(url, forKey: ISMChatAppConstants.userDefaultUserProfileImage)
    }
    
    public func setnotification(on : Bool){
        UserDefaults.standard.set(on, forKey: ISMChatAppConstants.userDefaultKeepNotificationOn)
    }
    
    public func setUserBio(bio : String){
        UserDefaults.standard.set(bio, forKey: ISMChatAppConstants.userDefaultUserBio)
    }
    
    
    public func setLastSeen(showLastSeen : Bool){
        UserDefaults.standard.set(showLastSeen, forKey: ISMChatAppConstants.userDefaultLastSeen)
    }
    
    
    // MARK: - GETTERS
    
    public func getUserId() -> String {
        guard let userId = UserDefaults.standard.string(forKey: ISMChatAppConstants.userDefaultUserId) else { return "" }
        return userId
    }
    
    public func getUserToken() -> String {
        guard let userToken = UserDefaults.standard.string(forKey: ISMChatAppConstants.userDefaultUserToken) else { return ""}
        return userToken
    }
    
    public func getEmailId() -> String {
        guard let email = UserDefaults.standard.string(forKey: ISMChatAppConstants.userDefaultUserEmailId) else { return ""}
        return email
    }
    
    public func getUserName() -> String {
        guard let userName = UserDefaults.standard.string(forKey: ISMChatAppConstants.userDefaultUserName) else { return ""}
        return userName
    }
    
    public func getUserProfilePicture() -> String {
        guard let url = UserDefaults.standard.string(forKey: ISMChatAppConstants.userDefaultUserProfileImage) else { return ""}
        return url
    }
    
    public func getUserBio() -> String {
        guard let url = UserDefaults.standard.string(forKey: ISMChatAppConstants.userDefaultUserBio) else { return ""}
        return url
    }
    
    public func getNotificationStatus() -> Bool {
        return UserDefaults.standard.bool(forKey: ISMChatAppConstants.userDefaultKeepNotificationOn)
    }
    
    public func getLastSeenStatus() -> Bool {
        return UserDefaults.standard.bool(forKey: ISMChatAppConstants.userDefaultLastSeen)
    }
    
    
    // MARK: - DEFAULTS
    
    public func clearUserSession(){
        UserDefaults.standard.removeObject(forKey: ISMChatAppConstants.userDefaultUserId)
        UserDefaults.standard.removeObject(forKey: ISMChatAppConstants.userDefaultUserToken)
        UserDefaults.standard.removeObject(forKey: ISMChatAppConstants.userDefaultUserEmailId)
        UserDefaults.standard.removeObject(forKey: ISMChatAppConstants.userDefaultUserName)
        UserDefaults.standard.removeObject(forKey: ISMChatAppConstants.userDefaultUserProfileImage)
        UserDefaults.standard.removeObject(forKey: ISMChatAppConstants.userDefaultKeepNotificationOn)
        UserDefaults.standard.removeObject(forKey: ISMChatAppConstants.userDefaultUserBio)
        UserDefaults.standard.removeObject(forKey: ISMChatAppConstants.userDefaultLastSeen)
    }
}

public struct ISMChatAppConstants {
    static let userDefaultUserToken = "ismChatSdkUserToken"
    static let userDefaultUserEmailId = "ismChatSdkUserEmail"
    static let userDefaultUserId = "ismChatSdkUserId"
    static let userDefaultUserName = "ismChatSdkUserName"
    static let userDefaultUserProfileImage = "ismChatSdkUserProfileImage"
    static let userDefaultKeepNotificationOn = "ismChatSdkNotification"
    static let userDefaultUserBio = "ismChatSdkUserBio"
    static let userDefaultLastSeen = "ismChatsdkLastSeen"
}

