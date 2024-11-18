//
//  File.swift
//  
//
//  Created by Rasika Bharati on 18/11/24.
//

import Foundation
import SwiftUI


struct ISMChatExpandableText: View {
    @State private var expanded: Bool = false
    @State private var truncated: Bool = false
    private var text: String
    private var isReceived : Bool
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    let lineLimit: Int

    init(_ text: String, lineLimit: Int,isReceived: Bool) {
        self.text = text
        self.lineLimit = lineLimit
        self.isReceived = isReceived
    }

    private var moreLessText: String {
        if !truncated {
            return ""
        } else {
            return self.expanded ? "Read less" : " Read more"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(text)
                .lineLimit(expanded ? nil : lineLimit)
                .font(appearance.fonts.messageListMessageText)
                .foregroundColor(isReceived ? appearance.colorPalette.messageListMessageTextReceived :  appearance.colorPalette.messageListMessageTextSend)
                .background(
                    Text(text).lineLimit(lineLimit)
                        .font(appearance.fonts.messageListMessageText)
                        .foregroundColor(isReceived ? appearance.colorPalette.messageListMessageTextReceived :  appearance.colorPalette.messageListMessageTextSend)
                        .background(GeometryReader { visibleTextGeometry in
                            ZStack { //large size zstack to contain any size of text
                                Text(self.text)
                                    .font(appearance.fonts.messageListMessageText)
                                    .foregroundColor(isReceived ? appearance.colorPalette.messageListMessageTextReceived :  appearance.colorPalette.messageListMessageTextSend)
                                    .background(GeometryReader { fullTextGeometry in
                                        Color.clear.onAppear {
                                            self.truncated = fullTextGeometry.size.height > visibleTextGeometry.size.height
                                        }
                                    })
                            }
                            .frame(height: .greatestFiniteMagnitude)
                        })
                        .hidden() //keep hidden
            )
            if truncated {
                Button(action: {
                    withAnimation {
                        expanded.toggle()
                    }
                }, label: {
                    Text(moreLessText)
                        .font(appearance.fonts.messageListMessageMoreAndLess)
                        .foregroundColor(isReceived ? appearance.colorPalette.messageListMessageMoreAndLessReceived :  appearance.colorPalette.messageListMessageMoreAndLessSend)
                })
            }
        }
    }
}

