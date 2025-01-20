# ISOMETRIKCHAT

This project is a chat SDK that you can integrate into your apps to add chat flow functionality.

## Installation


## Usage

1. Default Values: Set the default values for account ID, project ID, keyset ID, license key, app secret, user secret, MQTT host, and port.

2. User Information: Retrieve user information such as user ID, user name, user email, and user profile image from the keychain.

3. Attachments and Features: Specify the types of attachments and features you need in the chat.

4. Conversation Types: Specify the types of conversations you need (e.g., one-to-one, group, broadcast).

5. Customizations: Configure custom colors, fonts, images, and message bubble type.

6. Configuration Objects: Create configuration objects for the app and user.

7. Initialization: Initialize the ChatSDK and ChatSDK UI with the provided configurations.


func initializeChatIsometrik(_ completion: @escaping ()->Void){
    
    //add what attachments you need only
    let attachment : [ISMChatConfigAttachmentType] = [.camera,.gallery,.document,.location,.contact]
    
    //add what features u need only
    let feature : [ISMChatConfigFeature] = [.forward,.edit,.audio,.reply,.audiocall,.videocall,.gif,.reaction]
    
    // add here what type of conversations type u need
    let conversationTypes : [ISMChatConversationTypeConfig] = [.OneToOneConversation,.GroupConversation,.BroadCastConversation]
    
    // add images , fonts, colors and bubbleType as per requirement here
    let customColors = ISMChatColorPalette()
    let customFonts = ISMChatFonts()
    let customImages = ISMChatImages()
    let messageBubbleType : ISMChatBubbleType = .BubbleWithOutTail
    let customPlaceholder = ISMChatPlaceholders() // u can pass anyView here
    let customFontNames = ISMChatCustomFontNames(light: "ProductSans-Light", regular: "ProductSans-Regular", bold: "ProductSans-Bold", medium: "ProductSans-Medium", italic: "ProductSans-Italic")
    
    
    let appConfig = ISMChatConfiguration(accountId: accountId, projectId: projectId, keySetId: keysetId, licensekey: licenseKey, MQTTHost: MQTTHost, MQTTPort: MQTTPort, appSecret: appSecret, userSecret: userSecret, authToken: authToken)
    
    let userConfig = ISMChatUserConfig(userToken: authToken, userId: userId, userName: userName, userEmail: userEmail, userProfileImage: userProfileImage)
    
    //For isometricChat
    ISMChatSdk.getInstance().appConfiguration(appConfig: appConfig, userConfig: userConfig)
    
    //For isometricChatUI
    ISMChatSdkUI.getInstance().appConfiguration(chatProperties: ISMChatPageProperties(attachments: attachment, features: feature, conversationType: conversationTypes, hideNavigationBarForConversationList: true, allowToNavigateToAppProfile: true, createConversationFromChatList: false, otherConversationList: true, showCustomPlaceholder: true, isOneToOneGroup: false), appearance: ISMAppearance(colorPalette: customColors, images: customImages, fonts: customFonts, messageBubbleType: messageBubbleType, placeholders: customPlaceholder, customFontNames: customFontNames))
    
    return ISMChatSdk.getInstance()
}



8. For call, you need to add this func in AppDelegate (didFinishLaunchingWithOptions)
"registerPushKit()"


extension AppDelegate : PKPushRegistryDelegate{
    
    func registerPushKit(){
        let mainQueue = DispatchQueue.main
        let callRegistry = PKPushRegistry(queue: mainQueue)
        callRegistry.delegate = self
        // Register to receive push notifications
        callRegistry.desiredPushTypes = [PKPushType.voIP]
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        ISMCallManager.shared.pushRegistry(registry, didUpdate: pushCredentials, for: type)
    }
    
    
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType){
        ISMCallManager.shared.pushRegistry(registry, didReceiveIncomingPushWith: payload, for: .voIP,completion: nil)
    }
    
    func pushRegistry(_ registry: PKPushRegistry,
                      didReceiveIncomingPushWith payload: PKPushPayload,
                      for type: PKPushType,
                      completion: @escaping () -> Void) {
        if type == .voIP {
            ISMCallManager.shared.pushRegistry(registry, didReceiveIncomingPushWith: payload, for: .voIP) {
                completion()
            }
        }
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        if type == .voIP {
            ISMCallManager.shared.invalidatePushKitAPNSDeviceToken(registry, type: type)
        }
    }
}


9. Add this in AppDelegate (didFinishLaunchingWithOptions) for GoogleServices and GooglePlaces used in Chat for sharing location.
        GMSServices.provideAPIKey("")
        GMSPlacesClient.provideAPIKey("")


10. Add this in AppDelegate (didRefreshRegistrationToken) to subscribe topic
        Messaging.messaging().subscribe(toTopic: ISMChatHelper.subscribeFCM()) { (error) in
            if error != nil {
                print("errror fcm topic ", error as Any)
            }
        }
        
        
        
11. Share Post/ Reel
        let viewModel = ChatsViewModel(ismChatSDK: ISMChatSdk.getInstance())
        viewModel.sharePost(user: UserDB(), postId: postId/reelId, postURL: "", postCaption: ""){}
        Note - post Url should be image
        
12. You can create you own UI, and pass in chat initialize
                CustomMessageBubbleViewRegistry.shared.register(customType: "AttachmentMessage:Text", view: TextMessageView.self)
                CustomConversationListCellViewRegistry.shared.register(view: ConversationListMessageView.self)  
                
            struct TextMessageView: CustomMessageBubbleViewProvider {
                static func parseData(_ data: IsometrikChat.MessagesDB) -> IsometrikChat.MessagesDB? {
                return data
                }
                typealias ViewData = MessagesDB

                static func createView(data: MessagesDB) -> some View {

                return Text(data.metaDataJsonString ?? "")
                .font(.headline)
            }
            

            struct ConversationListMessageView: CustomConversationListCellViewProvider {
                static func parseData(_ data: IsometrikChat.ConversationDB) -> IsometrikChat.ConversationDB? {
                return data
                }

                typealias ViewData = ConversationDB

                static func createView(data: ConversationDB) -> some View {

                return Text(data.lastMessageDetails?.body ?? "")
                .font(.headline)
             }
           }
           
           
           You need to pass UI for message bubble for all customTypes
           In chatProperties pass "useCustomViewRegistered" key as true.

}      


# Logout

Add this code when u logout

        Messaging.messaging().unsubscribe(fromTopic: ISMChatHelper.unSubscribeFCM(userId: userId))
        ISMChatSdk.getInstance().onTerminate(userId: IsomertricChatid ?? "")
        ISMChatSdk.sharedInstance = nil
        
Profile Switch:
Add this code when u have mutiple profiles in one account

        Messaging.messaging().unsubscribe(fromTopic: ISMChatHelper.unSubscribeFCM(userId: userId))
        ISMChatSdk.getInstance().onProfileSwitch(oldUserId : String,appConfig : ISMChatConfiguration, userConfig : ISMChatUserConfig,hostFrameworkType : FrameworkType,conversationListViewControllerName : UIViewController.Type?,messagesListViewControllerName : UIViewController.Type?)


