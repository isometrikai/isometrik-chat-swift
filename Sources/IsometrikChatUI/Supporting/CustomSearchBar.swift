//
//  SwiftUIView.swift
//  
//
//  Created by Rasika Bharati on 19/08/24.
//

import SwiftUI

public struct CustomSearchBar: View {
    @Binding var searchText: String
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    
    public var body: some View {
        HStack(alignment: .center, spacing: 5) {
            appearance.images.searchIcon
                .resizable()
                .frame(width: 14, height: 14, alignment: .center)
            
            TextField("Search", text: $searchText) // Hide placeholder when focused
                .font(appearance.fonts.searchbarText)
                .padding(.vertical, 8) // Adjust padding to ensure indicator visibility
                .padding(.horizontal, 5) // Extra horizontal padding to prevent cropping
                .background(Color.clear)
                .cornerRadius(10)
        }
        .frame(height: 38)
        .padding(.horizontal, 15)
        .background(appearance.colorPalette.searchBarBackground)
        .cornerRadius(9)
    }
}

