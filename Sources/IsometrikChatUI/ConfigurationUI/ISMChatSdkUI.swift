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
    
    public var preferredLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"
    
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
    
    
    
    public func appConfiguration(chatProperties : ISMChatPageProperties? = ISMChatPageProperties(),appearance : ISMAppearance? = ISMAppearance(),fontNames : ISMChatCustomFontNames? = ISMChatCustomFontNames(),customSearchBar: ISMChatCustomSearchBar? = ISMChatCustomSearchBar()) {
        self.fontNames = fontNames
        
        //UI Properties
        chatUIProperties = chatProperties
        
        customSearch = customSearchBar
        
       //Appearance
        appAppearance = ISMChatAppearance(appearance: appearance ?? ISMAppearance())
    }
    
    public func configureLocalization(languageCode: String) {
        preferredLanguage = languageCode
    }
}
