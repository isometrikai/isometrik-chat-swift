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
    private var chatUIProperties: ISMChat_PageProperties?
    
    private var appAppearance: ISMChat_Appearance?
    
    private static var sharedInstance : ISMChatSdkUI!
    
    public static func getInstance()-> ISMChatSdkUI{
        if sharedInstance == nil {
            sharedInstance = ISMChatSdkUI()
        }
        return sharedInstance
    }
    
    public func getChatProperties() -> ISMChat_PageProperties {
        if chatUIProperties == nil {
            fatalError("Create configuration before trying to access chat Properties object.")
        }
        return chatUIProperties!
    }
    
    public func getAppAppearance() -> ISMChat_Appearance{
        if appAppearance == nil{
            print("Create configuration before trying to access user session object.")
        }
        return appAppearance!
    }
    
    
    
    public func appConfiguration(conversationConfig : [ISMChat_ConversationTypeConfig],attachments : [ISMChat_ConfigAttachmentType],features : [ISMChat_ConfigFeature],customColors: ISMChat_ColorPalette, customFonts: ISMChat_Fonts,customImages: ISMChat_Images,customMessageBubbleType : ISMChat_BubbleType) {
        
        //UI Properties
        chatUIProperties = ISMChat_PageProperties(attachments: attachments, features: features, conversationType: conversationConfig)
        
       //Appearance
        let appearance = ISMAppearance(colorPalette: customColors, images: customImages, fonts: customFonts,messageBubbleType: customMessageBubbleType)
        appAppearance = ISMChat_Appearance(appearance: appearance)
    }
}
