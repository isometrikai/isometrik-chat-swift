//
//  CustomViewRegistry.swift
//  IsometrikChat
//
//  Created by Rasika Bharati on 03/01/25.
//

import IsometrikChat
import SwiftUI
import Foundation

/// Protocol defining requirements for custom message bubble view providers
/// Allows creation of custom views for different message types in the chat
public protocol CustomMessageBubbleViewProvider {
    /// The type of data model required for the view
    associatedtype ViewData
    /// The type of SwiftUI view to be rendered
    associatedtype ContentView: View
    
    /// Parses raw message data into the required view data model
    /// - Parameter data: Raw message data from database
    /// - Returns: Optional parsed view data
    static func parseData(_ data: MessagesDB) -> ViewData?
    
    /// Creates a SwiftUI view using the parsed data
    /// - Parameter data: Parsed view data
    /// - Returns: SwiftUI view to be rendered
    static func createView(data: ViewData) -> ContentView
}

/// Registry for managing custom message bubble views
/// Implements singleton pattern for global access
public class CustomMessageBubbleViewRegistry {
    /// Shared instance for singleton access
    public static let shared = CustomMessageBubbleViewRegistry()
    
    /// Dictionary storing view builders for different custom message types
    private var viewBuilders: [String: (MessagesDB) -> AnyView] = [:]
    
    /// Registers a custom view provider for a specific message type
    /// - Parameters:
    ///   - type: String identifier for the custom message type
    ///   - view: The provider type conforming to CustomMessageBubbleViewProvider
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
    
    /// Retrieves the appropriate view for a given message
    /// - Parameter message: Message data from database
    /// - Returns: A type-erased SwiftUI view
    public func view(for message: MessagesDB) -> AnyView {
        return viewBuilders[message.customType]?(message) ??
        AnyView(Text(message.body ?? ""))
    }
}

/// Protocol defining requirements for custom conversation list cell view providers
public protocol CustomConversationListCellViewProvider {
    associatedtype ViewData
    associatedtype ContentView: View
    
    /// Parses conversation data into the required view data model
    static func parseData(_ data: ISMChatConversationDB) -> ViewData?
    /// Creates a SwiftUI view for the conversation list cell
    static func createView(data: ViewData) -> ContentView
}

/// Registry for managing custom conversation list cell views
public class CustomConversationListCellViewRegistry {
    /// Shared instance for singleton access
    public static let shared = CustomConversationListCellViewRegistry()
    
    /// Storage for the default view builder
    private var defaultViewBuilder: ((ISMChatConversationDB) -> AnyView)?
    
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
    
    public func view(for message: ISMChatConversationDB) -> AnyView {
        if let defaultBuilder = defaultViewBuilder {
            return defaultBuilder(message)
        }
        return AnyView(Text(message.lastMessageDetails?.body ?? ""))
    }
}

/// Protocol defining requirements for custom message view header providers
public protocol CustomMessageViewHeaderProvider {
    associatedtype ViewData
    associatedtype ContentView: View
    
    /// Parses conversation detail and messages into the required view data model
    static func parseData(_ data: ISMChatConversationDetail, messages: [MessagesDB]) -> ViewData?
    /// Creates a SwiftUI view for the message view header
    static func createView(data: ViewData) -> ContentView
}

public class CustomMessageViewHeaderRegistry {
    public static let shared = CustomMessageViewHeaderRegistry()
    
    private var defaultViewBuilder: ((ISMChatConversationDetail,[MessagesDB]) -> AnyView)?
    
    public func register<Provider: CustomMessageViewHeaderProvider>(
        view: Provider.Type
    ) {
        defaultViewBuilder = { data,messages in
            if let parsedData = Provider.parseData(data, messages: messages) {
                return AnyView(Provider.createView(data: parsedData))
            }
            return AnyView(Text("Unable to render default view"))
        }
    }
    
    public func view(for data: ISMChatConversationDetail,messages : [MessagesDB]) -> AnyView {
        if let defaultBuilder = defaultViewBuilder {
            return defaultBuilder(data, messages)
        }
        return AnyView(Text(""))
    }
}


