//
//  SwiftUIView.swift
//  
//
//  Created by Rasika Bharati on 19/08/24.
//

import SwiftUI

public struct CustomSearchBar: View {
    @Binding var searchText: String
    @State public var themeFonts = ISMChatSdkUI.getInstance().getAppAppearance().appearance.fonts
    @State public var themeColor = ISMChatSdkUI.getInstance().getAppAppearance().appearance.colorPalette
    @State public var themeImage = ISMChatSdkUI.getInstance().getAppAppearance().appearance.images
    
    public var body: some View {
        HStack(alignment: .center, spacing: 5) {
            themeImage.searchIcon
                .resizable()
                .frame(width: 14, height: 14, alignment: .center)
            
            TextField("Search", text: $searchText) // Hide placeholder when focused
                .font(themeFonts.searchbarText)
                .padding(.vertical, 8) // Adjust padding to ensure indicator visibility
                .padding(.horizontal, 5) // Extra horizontal padding to prevent cropping
                .background(Color.clear)
                .cornerRadius(10)
        }
        .frame(height: 38)
        .padding(.horizontal, 15)
        .background(themeColor.searchBarBackground)
        .cornerRadius(9)
    }
}

