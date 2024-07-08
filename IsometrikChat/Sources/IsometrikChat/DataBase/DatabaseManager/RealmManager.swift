//
//  RealmManager.swift
//  ISMChatSdk
//
//  Created by Rahul Iphone123 on 14/07/23.
//

import Foundation
import RealmSwift

class RealmManager: ObservableObject {
    
    private(set) var localRealm: Realm?
    
    @Published var storeConv: [ConversationDB] = []
    @Published var conversations: [ConversationDB] = []
    @Published var allMessages : [MessagesDB]? = []
    @Published var messages : [[MessagesDB]] = [[]]
    @Published var localMessages : [MessagesDB]? = []
    @Published var medias : [MediaDB]? = []
    @Published var linksMedia : [MessagesDB]? = []
    @Published var filesMedia : [MediaDB]? = []
    @Published var parentMessageIdToScroll : String = ""
    @Published var broadcasts : [BroadCastListDB] = []
    
     var userSession = ISMChatSdk.getInstance().getUserSession()
    
    init() {
        openRealm()
        getAllConversations()
        print("localUrl" , databaseURL() ?? "")
    }
    
    func databaseURL() -> URL?{
        return localRealm?.configuration.fileURL
    }
    
    func openRealm() {
        do {
            // always update schemaversion when you do add or remove param from local db
            let config = Realm.Configuration(
                schemaVersion: 17)
            Realm.Configuration.defaultConfiguration = config
            localRealm = try Realm()
        } catch {
            print("Error opening Realm", error)
        }
    }
    
    //MARK: - delete all data of local db
    func deleteAllData() {
        do {
            let realm = try Realm()
            try realm.write {
                realm.deleteAll()
            }
        } catch let error as NSError {
            print("Error deleting all data: \(error.localizedDescription)")
            // Handle the error as needed, such as showing an alert to the user
        }
    }
}
