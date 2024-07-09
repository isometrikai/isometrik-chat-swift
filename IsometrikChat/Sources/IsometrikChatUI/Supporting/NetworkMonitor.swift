//
//  NetworkMonitor.swift
//  ISMChatSdk
//
//  Created by Rahul Iphone123 on 22/07/23.
//

import Foundation
import SwiftUI
import Network

public class NetworkMonitor: ObservableObject {
    public let networkMonitor = NWPathMonitor()
    public let workerQueue = DispatchQueue(label: "Monitor")
    public var isConnected = false

    public init() {
        networkMonitor.pathUpdateHandler = { path in
            self.isConnected = path.status == .satisfied
            Task {
                await MainActor.run {
                    self.objectWillChange.send()
                }
            }
        }
        networkMonitor.start(queue: workerQueue)
    }
}
