//
//  SectionTitles.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 29/10/23.
//

import Foundation
import SwiftUI
import UIKit

/// A SwiftUI view that displays a vertical list of section index titles with drag-to-scroll functionality
/// Similar to UITableView's section index titles in UIKit
struct SectionIndexTitles: View {
    
    //MARK: - PROPERTIES
    /// ScrollViewProxy to programmatically control scrolling
    let proxy: ScrollViewProxy
    /// Array of section titles to display
    let titles: [String]
    /// Tracks the current drag location using GestureState
    /// Resets to .zero when drag ends
    @GestureState private var dragLocation: CGPoint = .zero
    
    //MARK: - BODY
    var body: some View {
        VStack {
            ForEach(titles, id: \.self) { title in
                Text(title)
                    .foregroundColor(Color.bluetype)
                    .font(Font.regular(size: 10))
                    .background(dragObserver(title: title))
            }
        }
        .gesture(
            // Continuous drag gesture that updates dragLocation
            // minimumDistance: 0 ensures immediate response to touch
            DragGesture(minimumDistance: 0, coordinateSpace: .global)
                .updating($dragLocation) { value, state, _ in
                    state = value.location
                }
        )
    }
    
    //MARK: - CONFIGURE
    /// Creates a geometry reader to observe drag interactions for each title
    /// - Parameter title: The section title to observe
    /// - Returns: A view that monitors drag interactions
    func dragObserver(title: String) -> some View {
        GeometryReader { geometry in
            dragObserver(geometry: geometry, title: title)
        }
    }
    
    /// Handles drag detection and triggers scrolling when drag intersects with a title
    /// - Parameters:
    ///   - geometry: The geometry proxy for the title's view
    ///   - title: The section title being observed
    /// - Returns: An invisible rectangle that serves as the hit testing area
    func dragObserver(geometry: GeometryProxy, title: String) -> some View {
        if geometry.frame(in: .global).contains(dragLocation) {
            // Scroll to the title when user's finger intersects with its frame
            // Dispatched async to prevent potential animation conflicts
            DispatchQueue.main.async {
                proxy.scrollTo(title, anchor: .center)
            }
        }
        return Rectangle().fill(Color.clear)
    }
}
