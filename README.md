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


func initializeChatIsometrik() -> ISMChatSdk{
    
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
    
    let appConfig = ISMChatConfiguration(accountId: accountId, projectId: projectId, keySetId: keysetId, licensekey: licenseKey, MQTTHost: MQTTHost, MQTTPort: MQTTPort, appSecret: appSecret, userSecret: userSecret, authToken: authToken)
    
    let userConfig = ISMChatUserConfig(userToken: authToken, userId: userId, userName: userName, userEmail: userEmail, userProfileImage: userProfileImage)
    
    //For isometricChat
    ISMChatSdk.getInstance().appConfiguration(appConfig: appConfig, userConfig: userConfig)
    
    //For isometricChatUI
    ISMChatSdkUI.getInstance().appConfiguration(conversationConfig: conversationTypes, attachments: attachment, features: feature, customColors: customColors, customFonts: customFonts, customImages: customImages, customMessageBubbleType: messageBubbleType)
    
    //Call initializeCall func here for call functionality
    initializeCall()
    
    return ISMChatSdk.getInstance()
}



8. For call functionality in Chat u need to initialize ISMSwiftCall,already called in above function.
func initializeCall(){
    let sdkConfig = ISMCallConfiguration.init(accountId: accountId, projectId: projectId, keysetId: keysetId, licenseKey: licenseKey, appSecret: appSecret, userSecret: userSecret)
    let isometrik = IsometrikCall(configuration: sdkConfig)
    isometrik.updateUserId(ChatKeychain.shared.userId ?? "")
    isometrik.updateUserToken(ChatKeychain.shared.authToken ?? "")
    ISMCallManager.shared.updatePushRegisteryToken()
}


9. For call, you need to add this func in AppDelegate (didFinishLaunchingWithOptions)
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


10. Add this in AppDelegate (didFinishLaunchingWithOptions) for GoogleServices and GooglePlaces used in Chat for sharing location.
        GMSServices.provideAPIKey("")
        GMSPlacesClient.provideAPIKey("")


11. Add this in AppDelegate (didRefreshRegistrationToken) to subscribe topic
        ISMChatHelper.subscribeFCM()


# Logout

Add this code when u logout

ISMChatSdk.getInstance().onTerminate()
IsometrikCall().clearSession()
ISMCallManager.shared.invalidatePushKitAPNSDeviceToken(type: .voIP)
