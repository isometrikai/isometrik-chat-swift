//
//  File.swift
//  
//
//  Created by Rasika Bharati on 20/09/24.
//

import Foundation
import UIKit
import SwiftUI

/// A SwiftUI view that wraps a UIScrollView to provide zooming functionality
/// for any SwiftUI content.
struct ISMZoomableScrollView<Content: View>: UIViewRepresentable {
    private var content: Content

    /// Initializes the zoomable scroll view with the given content
    /// - Parameter content: A closure that returns the content view to be made zoomable
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    /// Creates and configures the underlying UIScrollView
    /// - Parameter context: The context containing the coordinator
    /// - Returns: A configured UIScrollView instance
    func makeUIView(context: Context) -> UIScrollView {
        // Initialize the scroll view with zoom capabilities
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.maximumZoomScale = 10  // Allow up to 10x zoom
        scrollView.minimumZoomScale = 1   // Normal size at minimum
        scrollView.bouncesZoom = true     // Enable bounce effect when zooming

        // Configure the hosted SwiftUI view
        let hostedView = context.coordinator.hostingController.view!
        // Enable auto-resizing for proper scaling
        hostedView.translatesAutoresizingMaskIntoConstraints = true
        hostedView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hostedView.frame = scrollView.bounds
        
        // Add the hosted view and configure scroll indicators
        scrollView.addSubview(hostedView)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false

        return scrollView
    }

    /// Creates the coordinator to manage the UIScrollView's zooming behavior
    func makeCoordinator() -> Coordinator {
        return Coordinator(hostingController: UIHostingController(rootView: self.content))
    }

    /// Updates the view when SwiftUI updates occur
    /// - Parameters:
    ///   - uiView: The UIScrollView instance to update
    ///   - context: The context containing the coordinator
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        // Update the hosted content when SwiftUI updates
        context.coordinator.hostingController.rootView = self.content
        // Verify that the hosting controller's view is properly connected
        assert(context.coordinator.hostingController.view.superview == uiView)
    }

    /// Coordinator class that manages the UIScrollView's zooming behavior
    class Coordinator: NSObject, UIScrollViewDelegate {
        var hostingController: UIHostingController<Content>

        /// Initializes the coordinator with a hosting controller
        /// - Parameter hostingController: The UIHostingController that will contain the SwiftUI content
        init(hostingController: UIHostingController<Content>) {
            self.hostingController = hostingController
            self.hostingController.view.backgroundColor = UIColor.clear
        }

        /// Provides the view that should be zoomed within the scroll view
        /// - Parameter scrollView: The scroll view requesting the zoomable view
        /// - Returns: The view that should be zoomed
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return hostingController.view
        }
    }
}
