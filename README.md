# Isometrik Chat IOS SDK

`Isometrik Chat IOS SDK` is a package that provides chat functionality for iOS projects, supporting both UIKit and SwiftUI.

## Setup

For detailed Info.plist setup instructions, please refer to the guide below and add the required configurations to your project:

- [Detailed Setup](./README_SETUP.md)


## Usage

1. Default Values: Set the default values for account ID, project ID, keyset ID, license key, app secret, user secret, MQTT host, and port.

2. User Information: Retrieve user information such as user ID, user name, user email, and user profile image from the keychain.

3. Attachments and Features: Specify the types of attachments and features you need in the chat.

4. Conversation Types: Specify the types of conversations you need (e.g., one-to-one, group, broadcast).

5. Customizations: Configure custom colors, fonts, images, and message bubble type.

6. Configuration Objects: Create configuration objects for the app and user.

7. Initialization: Initialize the ChatSDK and ChatSDK UI with the provided configurations.

### Initialize IsometrikChat

```dart
let appConfig = ISMChatConfiguration(accountId: accountId, projectId: projectId, keySetId: keysetId, licensekey: licenseKey, MQTTHost: configuration.MQTTHost, MQTTPort: configuration.MQTTPort, appSecret: configuration.appSecret, userSecret: configuration.userSecret, authToken: token)

let userConfig = ISMChatUserConfig(userToken: token, userId: userId, userName: userName, userEmail: userEmail ?? "", userProfileImage: userProfileImage ?? "", userProfileType: "")

let framework : FrameworkType = .UIKit

let chatListHostViewController = ChatVC.self

let messageListHostViewController = MessageVC.self

ISMChatSdk.getInstance().appConfiguration(appConfig: appConfig, userConfig: userConfig, hostFrameworkType: framework, conversationListViewControllerName: chatListHostViewController, messagesListViewControllerName: messageListHostViewController, uploadOnExternalCDN: false, giphyApiKey: "")
```

##### Required Parameters

- `appConfig`: Contains essential configuration details that must be provided.
- `userConfig`: Holds user-specific properties required for the chat page.
- `hostFrameworkType`: Specifies the framework type; pass .UIKit or .SwiftUI.

##### Optional Parameters

- `conversationListViewControllerName`:  The host view controller for the chat list.
- `messagesListViewControllerName`: The host view controller for the message list.
- `uploadOnExternalCDN`: Pass true to store media in an external cloud.
- `giphyApiKey`: The API key required to enable GIFs and stickers.


### Initialize IsometrikChatUI

```dart
let chatProperties = ISMChatPageProperties(attachments: attachment, features: feature, conversationType: conversationTypes, hideNavigationBarForConversationList: true, allowToNavigateToAppProfile: true, createConversationFromChatList: false, otherConversationList: true, showCustomPlaceholder: true, isOneToOneGroup: false)

let appearance = ISMAppearance(colorPalette: customColors, images: customImages, fonts: customFonts, messageBubbleType: messageBubbleType, placeholders: customPlaceholder, customFontNames: customFontNames)

let customFontNames = ISMChatCustomFontNames(light: "ProductSans-Light", regular: "ProductSans-Regular", bold: "ProductSans-Bold", semiBold: "ProductSans-Bold", medium: "ProductSans-Medium", italic: "ProductSans-Italic")

let customSearchBar = ISMChatCustomSearchBar(height: 40, cornerRadius: 20, borderWidth: 0.75, searchBarBackgroundColor: Color(hex: "#F2F2F5"), searchBarBorderColor: Color(hex: "#F2F2F5"), showCrossButton: true, searchBarSearchIcon: Image("search_ecom"), searchCrossIcon: Image("chats_close"),sizeOfSearchIcon: CGSize(width: 13, height: 13),sizeofCrossIcon: CGSize(width: 12, height: 12), searchPlaceholderText: "Search", searchPlaceholderTextColor: Color(hex: "#bfbfca"), searchTextFont: Font.custom(Primary.Regular.rawValue, size: 14))

ISMChatSdkUI.getInstance().appConfiguration(chatProperties: chatProperties, appearance: appearance, fontNames: customFontNames, customSearchBar: customSearchBar)
```

##### Required Parameters
- none

##### Optional Parameters
- `chatProperties`: Includes attachments, features, conversation types, etc.
- `appearance`: Includes color palette, images, fonts, message bubble type, placeholders, time inside bubble, image sizes, constant strings, message list background image, and date formats.
- `fontNames`:  Allows you to pass custom fonts.
- `customSearchBar`: Enables you to create a custom search bar.


8. To enable audio call and video call features, add the following function in AppDelegate inside didFinishLaunchingWithOptions.

### Related Repositories

For call functionality, check out the Isometrik Call iOS SDK:
[Isometrik Call iOS](https://github.com/isometrikai/isometrik-call-ios)  


```dart

import PushKit

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
   registerPushKit()
}


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
```

9. Add the following in AppDelegate inside didFinishLaunchingWithOptions to configure Google Services and Google Places, which are used in chat for location sharing.

```dart
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    GMSServices.provideAPIKey("")
    GMSPlacesClient.provideAPIKey("")
}
```


10. Add this to subscribe to the chat notifications topic, passing the isometricChatUserId of the logged-in user.

```dart
Messaging.messaging().subscribe(toTopic: ISMChatHelper.subscribeFCM(userId: isometricChatUserId))
```      

11. Add this to unsubscribe to the chat notifications topic, passing the isometricChatUserId of the logged-in user.


```dart
Messaging.messaging().unsubscribe(fromTopic: ISMChatHelper.unSubscribeFCM(userId: isometricChatUserId))
``` 
        
12. You can create your own custom message bubble UI. Add the following code when initializing the chat.

```dart
CustomMessageBubbleViewRegistry.shared.register(customType: "AttachmentMessage:Text", view: TextMessageView.self)
CustomConversationListCellViewRegistry.shared.register(view: ConversationListMessageView.self)  

Example:

struct TextMessageView: CustomMessageBubbleViewProvider {
    static func parseData(_ data: IsometrikChat.MessagesDB) -> IsometrikChat.MessagesDB? {
        return data
    }
    typealias ViewData = MessagesDB

    static func createView(data: MessagesDB) -> some View {
        return Text(data.metaDataJsonString ?? "").font(.headline)
    }
}


struct ConversationListMessageView: CustomConversationListCellViewProvider {
    static func parseData(_ data: IsometrikChat.ConversationDB) -> IsometrikChat.ConversationDB? {
        return data
    }

    typealias ViewData = ConversationDB

    static func createView(data: ConversationDB) -> some View {
        return Text(data.lastMessageDetails?.body ?? "").font(.headline)
    }
}   
```    


13. Logout

```dart
Messaging.messaging().unsubscribe(fromTopic: ISMChatHelper.unSubscribeFCM(userId: userId))
ISMChatSdk.getInstance().onTerminate(userId: IsomertricChatUserid ?? "")
ISMChatSdk.sharedInstance = nil
```
        
14. Profile Switch:

Add this code when you have multiple profiles under one account to enable profile switching.

```dart
Messaging.messaging().unsubscribe(fromTopic: ISMChatHelper.unSubscribeFCM(userId: userId))
ISMChatSdk.getInstance().onProfileSwitch(oldUserId : String,appConfig : ISMChatConfiguration, userConfig : ISMChatUserConfig,hostFrameworkType : FrameworkType,conversationListViewControllerName : UIViewController.Type?,messagesListViewControllerName : UIViewController.Type?)
```


