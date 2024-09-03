//
//  MediaSliderView.swift
//  ISMChatSdk
//
//  Created by Rasika on 04/07/23.
//

import SwiftUI
import IsometrikChat

struct MediaSliderView: View {
    
    //MARK:  - PROPERTIES
    
    var viewModel = ChatsViewModel()
    var index = 2
    var messageId = "0"
    @State var description : String = ""
    @State var user : String = ""
    @EnvironmentObject var reamlManager : RealmManager
    @State var themeFonts = ISMChatSdkUI.getInstance().getAppAppearance().appearance.fonts
    @State var themeColor = ISMChatSdkUI.getInstance().getAppAppearance().appearance.colorPalette
    @State var themeImages = ISMChatSdkUI.getInstance().getAppAppearance().appearance.images
    @Environment(\.dismiss) var dismiss
    
    //MARK:  - BODY
    var body: some View {
        VStack {
            MediaSlider(viewModel: self.viewModel,index: messageId == "0" ? index : (reamlManager.medias?.firstIndex(where: {$0.messageId == self.messageId}) ?? 0),media: reamlManager.medias ?? [], description: $description, user: $user).environmentObject(reamlManager)
                .frame(maxHeight: .infinity, alignment: .center)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
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
        .navigationBarItems(leading: navigationBarLeadingButtons())
        .onAppear{
            print(index)
        }
    }
    
    func navigationBarLeadingButtons()  -> some View {
        Button(action : {}) {
            HStack{
                Button(action: {
                    dismiss()
                }) {
                    themeImages.backButton
                        .resizable()
                        .frame(width: 18, height: 18)
                }
            }
        }
    }
}
