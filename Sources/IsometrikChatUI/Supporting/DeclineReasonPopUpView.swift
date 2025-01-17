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
    
    // State to track the selected option
    @State var selectedOption: String? = nil
    var confirmAction: (String) -> Void
    var cancelAction: () -> Void
    @State private var reasonText: String = "" // State to hold user input
    private let maxCharacterLimit = 1000
    
    var body: some View {
        VStack(spacing: 32) {
            Text("Select why you can’t attend")
            List {
                ForEach(options, id: \.self) { option in
                    HStack {
                        // Radio button
                        Circle()
                            .strokeBorder(selectedOption == option ? Color.green : Color.gray, lineWidth: 2)
                            .background(Circle().fill(selectedOption == option ? Color.green : Color.clear))
                            .frame(width: 20, height: 20)
                        
                        // Option text
                        Text(option)
                            .font(.body)
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedOption = option
                    }
                }
            }.listStyle(.plain)
            
            if selectedOption == "Other"{
                Text("Reason")
                VStack(alignment: .trailing){
                    ZStack(alignment: .topLeading) {
                        // Placeholder text
                        if reasonText.isEmpty {
                            Text("Optional")
                                .foregroundColor(.gray)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 12)
                        }
                        
                        // Text editor
                        TextEditor(text: $reasonText)
                            .padding(8)
                            .frame(height: 106) // Adjust the height as needed
                    }
                    Text("\(reasonText.count)/\(maxCharacterLimit)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }.overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray, lineWidth: 1)
                )
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
        .padding(.horizontal, 0)
    }
}
