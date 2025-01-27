//
//  SwiftUIView.swift
//  IsometrikChat
//
//  Created by Rasika Bharati on 17/01/25.
//

import SwiftUI

/// A SwiftUI view that presents a popup for selecting reasons to decline an event/invitation
/// This view provides a list of predefined options and a custom text input for "Other" option
struct DeclineReasonPopUpView: View {
    // Predefined options for declining
    private let options = [
        "Prior commitments",
        "Travel limitations",
        "Health concerns",
        "Schedule conflicts",
        "Other"
    ]
    
    // MARK: - Properties
    @Binding var selectedOption: String? // Currently selected reason
    var confirmAction: (String) -> Void  // Callback for handling confirmation
    var cancelAction: () -> Void         // Callback for handling cancellation
    @State private var reasonText: String = "" // Custom reason text for "Other" option
    private let maxCharacterLimit = 1000
    var appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // MARK: - Header
            Text("Select why you can't attend")
                .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().bold, size: 16))
                .foregroundColor(Color(hex: "#0E0F0C"))
                .padding(.vertical, 20)
            
            // MARK: - Options List
            List {
                ForEach(options, id: \.self) { option in
                    HStack {
                        // Custom radio button implementation using images
                        if selectedOption == option {
                            appearance.images.selectedDeleteOptions
                                .resizable()
                                .frame(width: 24, height: 24, alignment: .center)
                        } else {
                            appearance.images.deSelectedDeleteOptions
                                .resizable()
                                .frame(width: 24, height: 24, alignment: .center)
                        }
                        
                        Text(option)
                            .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().regular, size: 16))
                            .foregroundColor(Color(hex: "#0E0F0C"))
                        
                        Spacer()
                    }.padding(.vertical,7)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedOption = option
                    }
                }.listRowSeparator(.hidden)
            }.listStyle(.plain)
                .listRowSeparator(.hidden)
                .padding(.bottom,20)
            
            // MARK: - Custom Reason Input
            // Only show text input field when "Other" is selected
            if selectedOption == "Other"{
                Text("Reason")
                    .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().regular, size: 14))
                    .foregroundColor(Color(hex: "#454745"))
                    .padding(.bottom,8)
                VStack(alignment: .trailing){
                    ZStack(alignment: .topLeading) {
                        // Placeholder text
                        
                        
                        // Text editor
                        TextEditor(text: $reasonText)
                            .padding(8)
                            .frame(height: 75) // Adjust the height as needed
                        
                        if reasonText.isEmpty {
                            Text("Optional")
                                .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().regular, size: 16))
                                .foregroundColor(Color(hex: "#6A6C6A"))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 12)
                        }
                    }
                    Text("\(reasonText.count)/\(maxCharacterLimit)")
                        .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().regular, size: 12))
                        .foregroundColor(Color(hex: "#454745"))
                        .padding()
                }.overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .padding(.bottom,20)
            }
            
            // MARK: - Action Buttons
            HStack {
                // Cancel button
                Button(action: cancelAction) {
                    Text("Cancel")
                        .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().semibold, size: 14))
                        .foregroundColor(Color(hex: "#163300"))
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(Color.white)
                        .cornerRadius(24)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color(hex: "#163300"), lineWidth: 1)
                        )
                }
                
                // Send response button
                Button {
                    // Handle response based on selection
                    if let selected = selectedOption {
                        // If "Other" is selected, send custom reason text
                        // Otherwise, send the selected predefined option
                        confirmAction(selected == "Other" ? reasonText : selected)
                    } else {
                        confirmAction("") // Send empty string if nothing selected
                    }
                } label: {
                    Text("Send response")
                        .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().semibold, size: 14))
                        .foregroundColor(Color.white)
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(Color(hex: "#FF3B30"))
                        .cornerRadius(24)
                }
            }
        }
        .padding()
        .background(Color.white)
    }
}
