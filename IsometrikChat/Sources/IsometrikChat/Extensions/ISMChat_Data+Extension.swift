//
//  Data+Extension.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 24/05/23.
//

import Foundation

extension Data {
    func decode<T:Codable>() throws -> T {
        return try JSONDecoder().decode(T.self, from: self)
    }
}
