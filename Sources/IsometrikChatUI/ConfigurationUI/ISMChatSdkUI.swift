//
//  File.swift
//  
//
//  Created by Rasika on 09/07/24.
//

import Foundation

public class ISMChatSdkUI{
    
    //MARK: - PROPERTIES
    //chat PROPERTIES
    private var chatUIProperties: ISMChatPageProperties?
    
    private var appAppearance: ISMChatAppearance?
    
    public static var sharedInstance : ISMChatSdkUI!
    
    public static func getInstance()-> ISMChatSdkUI{
        if sharedInstance == nil {
            sharedInstance = ISMChatSdkUI()
        }
        return sharedInstance
    }
    
    public func getChatProperties() -> ISMChatPageProperties {
        if chatUIProperties == nil {
            fatalError("Create configuration before trying to access chat Properties object.")
        }
        return chatUIProperties!
    }
    
    public func getAppAppearance() -> ISMChatAppearance{
        if appAppearance == nil{
            print("Create configuration before trying to access user session object.")
        }
        return appAppearance!
    }
    
    
    
    public func appConfiguration(chatProperties : ISMChatPageProperties,appearance : ISMAppearance) {
        
        //UI Properties
        chatUIProperties = chatProperties
        
       //Appearance
        appAppearance = ISMChatAppearance(appearance: appearance)
    }
}
