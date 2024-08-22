//
//  RealmManager.swift
//  ISMChatSdk
//
//  Created by Rahul Iphone123 on 14/07/23.
//

import Foundation
import RealmSwift

public class RealmManager: ObservableObject {
    
    private(set) var localRealm: Realm?
    
    @Published public var storeConv: [ConversationDB] = []
    @Published public var conversations: [ConversationDB] = []
    @Published public var allMessages : [MessagesDB]? = []
    @Published public var messages : [[MessagesDB]] = [[]]
    @Published public var localMessages : [MessagesDB]? = []
    @Published public var medias : [MediaDB]? = []
    @Published public var linksMedia : [MessagesDB]? = []
    @Published public var filesMedia : [MediaDB]? = []
    @Published public var parentMessageIdToScroll : String = ""
    @Published public var broadcasts : [BroadCastListDB] = []
    @Published public var storeBroadcasts: [BroadCastListDB] = []
    
    public var userSession = ISMChatSdk.getInstance().getUserSession()
    
    public static let shared = RealmManager()
    
    public init() {
        openRealm()
        getAllConversations()
        print("localUrl" , databaseURL() ?? "")
    }
    
    public func databaseURL() -> URL?{
        return localRealm?.configuration.fileURL
    }
    
    public func openRealm() {
        do {
            // always update schemaversion when you do add or remove param from local db
            let config = Realm.Configuration(
                schemaVersion: 23)
            Realm.Configuration.defaultConfiguration = config
            localRealm = try Realm()
        } catch {
            print("Error opening Realm", error)
        }
    }
    
    //MARK: - delete all data of local db
//    public func deleteAllData() {
//        do {
//            let realm = try Realm()
//            try realm.write {
//                realm.deleteAll()
//            }
//            try FileManager.default.removeItem(at:Realm.Configuration.defaultConfiguration.fileURL!) 
//        } catch let error as NSError {
//            print("Error deleting all data: \(error.localizedDescription)")
//            // Handle the error as needed, such as showing an alert to the user
//        }
//    }
    
    public func deleteAllData() {
        do {
            if let realmURL = Realm.Configuration.defaultConfiguration.fileURL {
                try FileManager.default.removeItem(at: realmURL)
                print("Realm deleted successfully.")
            }
            // After deletion, reinitialize Realm
            openRealm()
        } catch {
            print("Error deleting Realm file:", error)
        }
    }
}
