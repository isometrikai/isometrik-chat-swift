//
//  ISMLocationPlacesSubvIew.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 01/06/23.
//

import SwiftUI
import GooglePlaces
import IsometrikChat

struct PlaceRow: View {
    
    //MARK:  - PROPERTIES
    
    var place: GMSPlace
    @State var themeFonts = ISMChatSdkUI.getInstance().getAppAppearance().appearance.fonts
    @State var themeColor = ISMChatSdkUI.getInstance().getAppAppearance().appearance.colorPalette
    @State var themeImages = ISMChatSdkUI.getInstance().getAppAppearance().appearance.images
    
    //MARK:  - LIFECYCLE
    var body: some View {
        HStack{
            themeImages.locationLogo
                .resizable()
                .frame(width: 20, height: 20, alignment: .center)
            VStack {
                Text(place.name ?? "")
                    .font(themeFonts.messageListMessageText)
                    .foregroundColor(themeColor.messageListHeaderTitle)
            }
        }
    }
}
