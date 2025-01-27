//
//  ContentLengthPreference.swift
//  ISMChatSdk
//
//  Created by Rasika on 15/04/24.
//

import Foundation
import SwiftUI

/// A PreferenceKey that tracks and propagates content length measurements in the view hierarchy
///
/// This preference key is typically used to measure and communicate the size of content
/// from child views to parent views in SwiftUI.
struct ContentLengthPreference: PreferenceKey {
    /// The default value returned when no preference value is set
    /// Returns 0 as the base measurement
    static var defaultValue: CGFloat { 0 }
    
    /// Combines multiple preference values into a single value
    /// - Parameters:
    ///   - value: The current preference value that will be modified
    ///   - nextValue: A closure that returns the next preference value to be combined
    ///
    /// In this implementation, we simply take the latest value, overwriting any previous value.
    /// This is useful when we only care about the final measurement of a specific view.
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
