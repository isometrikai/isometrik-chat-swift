//
//  NetworkMonitor.swift
//  ISMChatSdk
//
//  Created by Rahul Iphone123 on 22/07/23.
//

import Foundation
import SwiftUI
import Network

/// A class that monitors network connectivity status using NWPathMonitor
/// This class provides real-time updates about the device's network connection state
public class NetworkMonitor: ObservableObject {
    /// The network path monitor instance that tracks connectivity
    public let networkMonitor = NWPathMonitor()
    
    /// A dedicated dispatch queue for network monitoring operations
    public let workerQueue = DispatchQueue(label: "Monitor")
    
    /// Boolean flag indicating if the device has an active network connection
    /// - true: Device is connected to the network
    /// - false: Device has no network connection
    public var isConnected = false

    /// Initializes the network monitor and starts observing network status changes
    public init() {
        // Set up path update handler to track network status changes
        networkMonitor.pathUpdateHandler = { path in
            // Update connection status based on network path satisfaction
            self.isConnected = path.status == .satisfied
            
            // Notify observers of the state change on the main thread
            Task {
                await MainActor.run {
                    self.objectWillChange.send()
                }
            }
        }
        
        // Start monitoring network status on the dedicated queue
        networkMonitor.start(queue: workerQueue)
    }
}
