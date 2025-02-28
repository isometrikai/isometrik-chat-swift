//
//  StorageMode.swift
//  IsometrikChat
//
//  Created by Rasika Bharati on 27/02/25.
//

import Foundation

public enum StorageMode {
    case local //only show data from localdb
    case remote //only show data from api
    case hybrid //first get data from api and save to local
}

public class ConfigurationService {
    static public let shared = ConfigurationService()
    public init() {}
    
    public var storageMode: StorageMode = .remote
}
