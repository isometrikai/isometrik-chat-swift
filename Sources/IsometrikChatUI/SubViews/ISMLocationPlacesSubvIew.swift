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
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    
    //MARK:  - LIFECYCLE
    var body: some View {
        HStack{
            appearance.images.locationLogo
                .resizable()
                .frame(width: 20, height: 20, alignment: .center)
            VStack {
                Text(place.name ?? "")
                    .font(appearance.fonts.messageListMessageText)
                    .foregroundColor(appearance.colorPalette.messageListHeaderTitle)
            }
        }
    }
}
