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
    @Published public var broadcasts : [BroadCastListDB] = []
    @Published public var storeBroadcasts: [BroadCastListDB] = []
    
    public var userData = ISMChatSdk.getInstance().getChatClient().getConfigurations().userConfig
    
    public static let shared = RealmManager()
    
    public init() {
        if localRealm != nil {
            getAllConversations()
        }else{
            openRealm(for: userData.userId)
            getAllConversations()
        }
        print("localUrl" , getRealmFileURL(for: userData.userId) ?? "")
    }
    
    public func openRealm(for userId: String) {
        do {
            let config = Realm.Configuration(
                fileURL: getRealmFileURL(for: userId),
                schemaVersion: 32
            )
            Realm.Configuration.defaultConfiguration = config
            localRealm = try Realm()
        } catch {
            print("Error opening Realm", error)
        }
    }
    
    
    public func deleteRealm(for userId: String) {
            do {
                if let realmURL = getRealmFileURL(for: userId) {
                    // Get all auxiliary file URLs
                    let lockFileURL = realmURL.appendingPathExtension("lock")
                    let noteFileURL = realmURL.appendingPathExtension("note")
                    let managementFileURL = realmURL.appendingPathExtension("management")
                    let logFileURL = realmURL.appendingPathComponent("log")
                    
                    // Delete main Realm file and auxiliary files
                    let filesToDelete = [realmURL, lockFileURL, noteFileURL, managementFileURL, logFileURL]
                    
                    for fileURL in filesToDelete {
                        if FileManager.default.fileExists(atPath: fileURL.path) {
                            try FileManager.default.removeItem(at: fileURL)
                        }
                    }
                    
                    // Clear Realm from memory cache
                    Realm.Configuration.defaultConfiguration = Realm.Configuration()
                    localRealm = nil
                    storeConv.removeAll()
                    conversations.removeAll()
                    allMessages = nil
                    messages.removeAll()
                    localMessages = nil
                    medias = nil
                    linksMedia = nil
                    filesMedia = nil
                    broadcasts.removeAll()
                    storeBroadcasts.removeAll()
                    
                    print("Realm deleted successfully.")
                }
            } catch {
                print("Error deleting Realm file:", error)
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
