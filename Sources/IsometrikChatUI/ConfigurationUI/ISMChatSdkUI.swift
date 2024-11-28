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
    
    private var customSearch : ISMChatCustomSearchBar?
    
    public static var sharedInstance : ISMChatSdkUI!
    
    public static func getInstance()-> ISMChatSdkUI{
        if sharedInstance == nil {
            sharedInstance = ISMChatSdkUI()
        }
        return sharedInstance
    }
    
    public func getChatProperties() -> ISMChatPageProperties {
        if chatUIProperties == nil {
            print("Create configuration before trying to access chat Properties object.")
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
    
    public func getCustomSearchBar() -> ISMChatCustomSearchBar{
        if customSearch == nil{
            print("Create configuration before trying to access font names object.")
        }
        return customSearch!
    }
    
    
    
    public func appConfiguration(chatProperties : ISMChatPageProperties,appearance : ISMAppearance,fontNames : ISMChatCustomFontNames? = nil,customSearchBar: ISMChatCustomSearchBar) {
        self.fontNames = fontNames
        
        //UI Properties
        chatUIProperties = chatProperties
        
        customSearch = customSearchBar
        
       //Appearance
        appAppearance = ISMChatAppearance(appearance: appearance)
    }
}
