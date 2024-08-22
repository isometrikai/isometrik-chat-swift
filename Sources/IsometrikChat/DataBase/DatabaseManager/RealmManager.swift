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
        if let localRealm = localRealm {
            getAllConversations()
        }else{
            openRealm(for: ISMChatSdk.getInstance().getUserSession().getUserId())
            getAllConversations()
        }
        print("localUrl" , getRealmFileURL(for: ISMChatSdk.getInstance().getUserSession().getUserId()) ?? "")
    }
    
    public func openRealm(for userId: String) {
        do {
            let config = Realm.Configuration(
                fileURL: getRealmFileURL(for: userId),
                schemaVersion: 23
            )
            Realm.Configuration.defaultConfiguration = config
            localRealm = try Realm()
        } catch {
            print("Error opening Realm", error)
        }
    }
    
    
    public func deleteRealm(for userId: String) {
        do {
            // First, delete all objects in the Realm to clean it up
            let realm = try Realm()
            try realm.write {
                realm.deleteAll()
            }
            
            // Then, attempt to delete the Realm file and related files
            if let realmURL = getRealmFileURL(for: userId) {
                let fileManager = FileManager.default
                let auxiliaryFileExtensions = ["lock", "note", "management"]

                // Delete the primary Realm file
                try fileManager.removeItem(at: realmURL)
                
                // Delete auxiliary Realm files
                for ext in auxiliaryFileExtensions {
                    try fileManager.removeItem(at: realmURL.appendingPathExtension(ext))
                }

                print("Realm deleted successfully.")
            }
        } catch {
            // Handle all errors in one place
            print("Error deleting Realm data or files: \(error.localizedDescription)")
        }
    }

    
    public func switchProfile(oldUserId : String,newUserId : String){
        deleteRealm(for: oldUserId)
        openRealm(for: newUserId)
        getAllConversations()
    }

    private func getRealmFileURL(for userId: String) -> URL? {
        // Use the app's documents directory to get a valid path
        let fileName = "realm_\(userId).realm"
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        return directory?.appendingPathComponent(fileName)
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
}
