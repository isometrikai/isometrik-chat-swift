//
//  ISMLocationPlacesSubvIew.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 01/06/23.
//

import SwiftUI
import GooglePlaces
import IsometrikChat

/// A SwiftUI view that represents a single place row in a location list
/// Used to display Google Places information in a consistent format
struct PlaceRow: View {
    
    //MARK: - PROPERTIES
    
    /// The Google Place object containing location details
    var place: GMSPlace
    
    /// UI appearance configuration instance for consistent styling
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    
    //MARK: - LIFECYCLE
    
    /// The body of the view that defines its content and layout
    var body: some View {
        HStack {
            // Display location pin icon
            appearance.images.locationLogo
                .resizable()
                .frame(width: 20, height: 20, alignment: .center)
            
            // Display place name in a vertical stack
            VStack {
                Text(place.name ?? "")
                    .font(appearance.fonts.messageListMessageText)
                    .foregroundColor(appearance.colorPalette.messageListHeaderTitle)
            }
        }
    }
}
