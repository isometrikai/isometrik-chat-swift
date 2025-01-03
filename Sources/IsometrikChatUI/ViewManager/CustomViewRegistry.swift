//
//  CustomViewRegistry.swift
//  IsometrikChat
//
//  Created by Rasika Bharati on 03/01/25.
//

import IsometrikChat
import SwiftUI
import Foundation

public protocol CustomMessageViewProvider {
    associatedtype ViewData
    associatedtype ContentView: View
    
    static func parseData(_ data: [String: Any]) -> ViewData?
    static func createView(data: ViewData) -> ContentView
}

public class CustomViewRegistry {
    public static let shared = CustomViewRegistry()
    
    private var viewBuilders: [String: ([String: Any]) -> AnyView] = [:]
    
    public func register<Provider: CustomMessageViewProvider>(
        for type: String,
        provider: Provider.Type
    ) {
        viewBuilders[type] = { message in
            if let parsedData = Provider.parseData(message) {
                return AnyView(Provider.createView(data: parsedData))
            }
            return AnyView(Text("Unable to render custom view"))
        }
    }
    
    public func view(for message: [String: Any]) -> AnyView {
        guard let customType = message["customType"] as? String else {
               return AnyView(Text("Invalid message: Missing customType"))
           }
        return viewBuilders[customType]?(message) ??
            AnyView(Text("No view registered for type: \(customType)"))
    }
}
