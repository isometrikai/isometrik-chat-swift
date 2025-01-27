//
//  File.swift
//  
//
//  Created by Rasika Bharati on 18/11/24.
//

import Foundation
import SwiftUI

/// A SwiftUI view that displays text with expandable/collapsible functionality
/// This component automatically detects if text needs truncation and shows a Read more/less button
struct ISMChatExpandableText: View {
    // MARK: - Properties
    
    /// Tracks if the text is currently expanded
    @State private var expanded: Bool = false
    
    /// Indicates if the text needs truncation
    @State private var truncated: Bool = false
    
    /// The text content to display
    private var text: String
    
    /// Indicates if this is a received message (affects styling)
    private var isReceived: Bool
    
    /// UI appearance configuration from the SDK
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    
    /// Maximum number of lines to show when collapsed
    let lineLimit: Int

    // MARK: - Initialization
    
    /// Creates a new expandable text view
    /// - Parameters:
    ///   - text: The text content to display
    ///   - lineLimit: Maximum number of lines to show when collapsed
    ///   - isReceived: Whether this is a received message
    init(_ text: String, lineLimit: Int, isReceived: Bool) {
        self.text = text
        self.lineLimit = lineLimit
        self.isReceived = isReceived
    }

    /// Computed property for the Read more/less button text
    private var moreLessText: String {
        if !truncated {
            return ""
        } else {
            return self.expanded ? "Read less" : " Read more"
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading) {
            // Main text view with dynamic line limit
            Text(text)
                .lineLimit(expanded ? nil : lineLimit)
                .font(appearance.fonts.messageListMessageText)
                .foregroundColor(isReceived ? appearance.colorPalette.messageListMessageTextReceived :  appearance.colorPalette.messageListMessageTextSend)
                .background(
                    // Hidden text view used to detect if truncation is needed
                    // by comparing the height of truncated vs full text
                    Text(text).lineLimit(lineLimit)
                        .font(appearance.fonts.messageListMessageText)
                        .foregroundColor(isReceived ? appearance.colorPalette.messageListMessageTextReceived :  appearance.colorPalette.messageListMessageTextSend)
                        .background(GeometryReader { visibleTextGeometry in
                            ZStack {
                                Text(self.text)
                                    .font(appearance.fonts.messageListMessageText)
                                    .foregroundColor(isReceived ? appearance.colorPalette.messageListMessageTextReceived :  appearance.colorPalette.messageListMessageTextSend)
                                    .background(GeometryReader { fullTextGeometry in
                                        // Compare heights to determine if text is truncated
                                        Color.clear.onAppear {
                                            self.truncated = fullTextGeometry.size.height > visibleTextGeometry.size.height
                                        }
                                    })
                            }
                            .frame(height: .greatestFiniteMagnitude)
                        })
                        .hidden()
                )
            
            // Read more/less button
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

