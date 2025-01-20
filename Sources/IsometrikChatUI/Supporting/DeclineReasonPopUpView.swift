//
//  SwiftUIView.swift
//  IsometrikChat
//
//  Created by Rasika Bharati on 17/01/25.
//

import SwiftUI

struct DeclineReasonPopUpView: View {
    private let options = [
        "Prior commitments",
        "Travel limitations",
        "Health concerns",
        "Schedule conflicts",
        "Other"
    ]
    
    @Binding var selectedOption: String?
    var confirmAction: (String) -> Void
    var cancelAction: () -> Void
    @State private var reasonText: String = "" // State to hold user input
    private let maxCharacterLimit = 1000
    var appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    
    var body: some View {
        VStack(alignment: .leading,spacing: 0) {
            Text("Select why you can’t attend")
                .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().bold, size: 16))
                .foregroundColor(Color(hex: "#0E0F0C"))
                .padding(.vertical,20)
            List {
                ForEach(options, id: \.self) { option in
                    HStack {
                        // Radio button
                        if selectedOption == option{
                            appearance.images.selectedDeleteOptions
                                .resizable()
                                .frame(width: 24, height: 24, alignment: .center)
                        }else{
                            appearance.images.deSelectedDeleteOptions
                                .resizable()
                                .frame(width: 24, height: 24, alignment: .center)
                        }
                        
                        // Option text
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
            
            HStack {
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
                Button {
                    if let selected = selectedOption{
                        if selected == "Other"{
                            confirmAction(reasonText)
                        }else{
                            confirmAction(selected)
                        }
                    }else{
                        confirmAction("")
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
