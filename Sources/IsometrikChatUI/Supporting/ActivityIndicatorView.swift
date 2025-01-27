//
//  ActivityIndicatorView.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 02/05/23.
//

import SwiftUI

/// A view that displays a loading spinner overlay
///
/// This view creates a semi-transparent overlay with a centered circular progress indicator.
/// Use this view when you need to show that content is loading or an operation is in progress.
///
/// Example usage:
/// ```
/// @State private var isLoading = false
/// 
/// var body: some View {
///     ZStack {
///         ContentView()
///         ActivityIndicatorView(isPresented: $isLoading)
///     }
/// }
/// ```
struct ActivityIndicatorView: View {
    
    // MARK: - Properties
    
    /// Binding to control the visibility of the activity indicator
    /// Set to `true` to show the indicator, `false` to hide it
    @Binding var isPresented: Bool
    
    // MARK: - Body
    
    var body: some View {
        if isPresented {  // Only show the overlay when isPresented is true
            ZStack {
                // Semi-transparent background overlay
                Color(.systemBackground)
                    .ignoresSafeArea()
                    .opacity(0.3)
                
                // Circular progress indicator
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .gray))
            }
        }
    }
}
