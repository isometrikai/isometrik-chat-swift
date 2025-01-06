//
//  CustomViewRegistry.swift
//  IsometrikChat
//
//  Created by Rasika Bharati on 03/01/25.
//

import IsometrikChat
import SwiftUI
import Foundation

public protocol CustomMessageBubbleViewProvider {
    associatedtype ViewData
    associatedtype ContentView: View
    
    static func parseData(_ data: MessagesDB) -> ViewData?
    static func createView(data: ViewData) -> ContentView
}


public class CustomMessageBubbleViewRegistry {
    public static let shared = CustomMessageBubbleViewRegistry()
    
    private var viewBuilders: [String: (MessagesDB) -> AnyView] = [:]
    
    public func register<Provider: CustomMessageBubbleViewProvider>(
        customType type: String,
        view: Provider.Type
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
        AnyView(Text(message.body ?? ""))
    }
}





public protocol CustomConversationListCellViewProvider {
    associatedtype ViewData
    associatedtype ContentView: View
    
    static func parseData(_ data: ConversationDB) -> ViewData?
    static func createView(data: ViewData) -> ContentView
}

public class CustomConversationListCellViewRegistry {
    public static let shared = CustomConversationListCellViewRegistry()
    
    private var defaultViewBuilder: ((ConversationDB) -> AnyView)?
    
    public func register<Provider: CustomConversationListCellViewProvider>(
        view: Provider.Type
    ) {
        defaultViewBuilder = { message in
            if let parsedData = Provider.parseData(message) {
                return AnyView(Provider.createView(data: parsedData))
            }
            return AnyView(Text("Unable to render default view"))
        }
    }
    
    public func view(for message: ConversationDB) -> AnyView {
        if let defaultBuilder = defaultViewBuilder {
            return defaultBuilder(message)
        }
        return AnyView(Text(message.lastMessageDetails?.body ?? ""))
    }
}

