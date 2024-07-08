//
//  MediaSliderView.swift
//  ISMChatSdk
//
//  Created by Rasika on 04/07/23.
//

import SwiftUI

struct MediaSliderView: View {
    
    //MARK:  - PROPERTIES
    
    var viewModel = ChatsViewModel(ismChatSDK: ISMChatSdk.getInstance())
    var index = 2
    var messageId = "0"
    @State var description : String = ""
    @State var user : String = ""
    @EnvironmentObject var reamlManager : RealmManager
    @State var themeFonts = ISMChatSdk.getInstance().getAppAppearance().appearance.fonts
    @State var themeColor = ISMChatSdk.getInstance().getAppAppearance().appearance.colorPalette
    
    //MARK:  - BODY
    var body: some View {
        VStack {
            MediaSlider(viewModel: self.viewModel,index: messageId == "0" ? index : (reamlManager.medias?.firstIndex(where: {$0.messageId == self.messageId}) ?? 0),media: reamlManager.medias ?? [], description: $description, user: $user).environmentObject(reamlManager)
                .frame(maxHeight: .infinity, alignment: .center)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text(user)
                        .font(themeFonts.mediaSliderHeader)
                        .foregroundColor(themeColor.mediaSliderHeader)
                    Text(description)
                        .font(themeFonts.mediaSliderDescription)
                        .foregroundColor(themeColor.mediaSliderDescription)
                }
            }
        }
        .onAppear{
            print(index)
        }
    }
}
