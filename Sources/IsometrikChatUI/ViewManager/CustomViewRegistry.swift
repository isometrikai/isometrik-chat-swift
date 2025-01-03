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
    
    static func parseData(_ data: MessagesDB) -> ViewData?
    static func createView(data: ViewData) -> ContentView
}

public class CustomViewRegistry {
    public static let shared = CustomViewRegistry()
    
    private var viewBuilders: [String: (MessagesDB) -> AnyView] = [:]
    
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
    
    public func view(for message: MessagesDB) -> AnyView {
        return viewBuilders[message.customType]?(message) ??
            AnyView(Text("No view registered for type: \(message.customType)"))
    }
}
