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
    let searchBar = ISMChatSdkUI.getInstance().getCustomSearchBar()
    let isDisabled : Bool?
    
    public var body: some View {
        HStack(alignment: .center, spacing: 5) {
            searchBar.searchBarSearchIcon
                .resizable()
                .frame(width: searchBar.sizeOfSearchIcon.width, height: searchBar.sizeOfSearchIcon.height, alignment: .center)
                .padding(.trailing,5)
            
            ZStack(alignment: .leading) {
                if searchText.isEmpty {
                    Text(searchBar.searchPlaceholderText)
                        .font(searchBar.searchTextFont)
                        .foregroundColor(searchBar.searchPlaceholderTextColor)
                        .padding(.leading,5)
                }
                TextField("", text: $searchText)
                    .disabled(isDisabled ?? false)
                    .font(searchBar.searchTextFont) // Apply font to the typed text
                    .padding(.vertical, 8)
                    .padding(.horizontal, 5)
                    .background(Color.clear)
                    .cornerRadius(10)
            }
            
            if searchBar.showCrossButton && !searchText.isEmpty{
                Button(action: {
                    searchText = ""
                }, label: {
                    searchBar.searchCrossIcon
                        .resizable()
                        .frame(width: searchBar.sizeofCrossIcon.width, height: searchBar.sizeofCrossIcon.height, alignment: .center)
                })
            }
        }
        .frame(height: CGFloat(searchBar.height))
        .padding(.horizontal, 15)
        .background(searchBar.searchBarBackgroundColor)
        .cornerRadius(CGFloat(searchBar.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: CGFloat(searchBar.cornerRadius))
                .stroke(searchBar.searchBarBorderColor, lineWidth: searchBar.borderWidth)
        )
    }
}

