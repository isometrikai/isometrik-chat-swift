//
//  PullToRefresh.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 14/03/23.
//

import Foundation
import SwiftUI

/// A custom pull-to-refresh implementation for SwiftUI views
/// This component tracks the scroll position and triggers a refresh action when pulled down
struct PullToRefresh: View {
    
    // MARK: - Properties
    
    /// The name of the coordinate space to track scroll position
    /// This must match the coordinateSpace name set on the parent ScrollView
    var coordinateSpaceName: String
    
    /// Closure to execute when refresh is triggered
    var onRefresh: () -> Void
    
    /// State to track if pull threshold has been reached and refresh should occur
    @State private var needRefresh: Bool = false
    
    // MARK: - View Body
    var body: some View {
        GeometryReader { geo in
            // Check if view is pulled down beyond threshold (50 points)
            if (geo.frame(in: .named(coordinateSpaceName)).midY > 50) {
                Spacer()
                    .onAppear {
                        // Mark that refresh should occur when released
                        needRefresh = true
                    }
            } 
            // Check if view has returned to original position
            else if (geo.frame(in: .named(coordinateSpaceName)).maxY < 10) {
                Spacer()
                    .onAppear {
                        // If we previously marked for refresh, trigger it now
                        if needRefresh {
                            needRefresh = false
                            onRefresh()
                        }
                    }
            }
            
            // Display either progress indicator or pull down arrow
            HStack {
                Spacer()
                if needRefresh {
                    ProgressView()
                } else {
                    Text("⬇️")
                }
                Spacer()
            }
        }
        // Offset the view upward to hide it until pulled
        .padding(.top, -50)
    }
}
