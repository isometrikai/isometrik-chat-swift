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
    
    private var fontNames : ISMChatCustomFontNames?
    
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
            print("Create configuration before trying to access appearance object.")
        }
        return appAppearance!
    }
    
    public func getCustomFontNames() -> ISMChatCustomFontNames{
        if fontNames == nil{
            print("Create configuration before trying to access font names object.")
        }
        return fontNames!
    }
    
    
    
    public func appConfiguration(chatProperties : ISMChatPageProperties,appearance : ISMAppearance,fontNames : ISMChatCustomFontNames? = nil) {
        self.fontNames = fontNames
        
        //UI Properties
        chatUIProperties = chatProperties
        
       //Appearance
        appAppearance = ISMChatAppearance(appearance: appearance)
    }
}
