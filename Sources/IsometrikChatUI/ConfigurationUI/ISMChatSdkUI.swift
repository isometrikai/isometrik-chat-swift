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
    
    
    
    public func appConfiguration(conversationConfig : [ISMChatConversationTypeConfig],attachments : [ISMChatConfigAttachmentType],features : [ISMChatConfigFeature],customColors: ISMChatColorPalette, customFonts: ISMChatFonts,customImages: ISMChatImages,customMessageBubbleType : ISMChatBubbleType,customPlaceholders : ISMChatPlaceholders? = nil,hideNavigationBarForConversationList : Bool,allowToNavigateToAppProfile : Bool,createConversationFromChatList : Bool,otherConversationList : Bool? = false,showCustomPlaceholders : Bool? = false) {
        
        //UI Properties
        chatUIProperties = ISMChatPageProperties(attachments: attachments, features: features, conversationType: conversationConfig, hideNavigationBarForConversationList: hideNavigationBarForConversationList, allowToNavigateToAppProfile: allowToNavigateToAppProfile, createConversationFromChatList: createConversationFromChatList, otherConversationList: otherConversationList ?? false,showCustomPlaceholder: showCustomPlaceholders ?? false)
        
       //Appearance
        let appearance = ISMAppearance(colorPalette: customColors, images: customImages, fonts: customFonts,messageBubbleType: customMessageBubbleType,placeholders: customPlaceholders ?? ISMChatPlaceholders())
        appAppearance = ISMChatAppearance(appearance: appearance)
    }
}
