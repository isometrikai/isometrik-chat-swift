//
//  SwiftUIView.swift
//  
//
//  Created by Rasika Bharati on 19/08/24.
//

import SwiftUI

/// A custom search bar component that provides a configurable search interface
/// with search icon, text input, and optional clear button.
public struct CustomSearchBar: View {
    // MARK: - Properties
    
    /// Binding for the search text that allows two-way communication with parent view
    @Binding var searchText: String
    
    /// Global appearance configuration from ISMChatSdkUI
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    
    /// Search bar specific configuration from ISMChatSdkUI
    let searchBar = ISMChatSdkUI.getInstance().getCustomSearchBar()
    
    /// Optional flag to disable the search bar interaction
    let isDisabled: Bool?
    
    // MARK: - Body
    
    public var body: some View {
        HStack(alignment: .center, spacing: 5) {
            // Search icon on the left
            searchBar.searchBarSearchIcon
                .resizable()
                .frame(width: searchBar.sizeOfSearchIcon.width, height: searchBar.sizeOfSearchIcon.height, alignment: .center)
                .padding(.trailing, 5)
            
            // Search text field with placeholder
            ZStack(alignment: .leading) {
                // Placeholder text shown when search field is empty
                if searchText.isEmpty {
                    Text(searchBar.searchPlaceholderText)
                        .font(searchBar.searchTextFont)
                        .foregroundColor(searchBar.searchPlaceholderTextColor)
                        .padding(.leading, 5)
                }
                
                // Actual text input field
                TextField("", text: $searchText)
                    .disabled(isDisabled ?? false)
                    .font(searchBar.searchTextFont)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 5)
                    .background(Color.clear)
                    .cornerRadius(10)
            }
            
            // Optional clear button shown when text is not empty
            if searchBar.showCrossButton && !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }, label: {
                    searchBar.searchCrossIcon
                        .resizable()
                        .frame(width: searchBar.sizeofCrossIcon.width, height: searchBar.sizeofCrossIcon.height, alignment: .center)
                })
            }
        }
        // Container styling
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

