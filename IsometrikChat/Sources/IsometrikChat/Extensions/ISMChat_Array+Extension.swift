//
//  Array+Extension.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 15/05/23.
//

import Foundation

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
