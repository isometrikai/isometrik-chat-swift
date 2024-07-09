//
//  RealmManager_Group.swift
//  ISMChatSdk
//
//  Created by Rasika on 10/06/24.
//

import Foundation
import RealmSwift

extension RealmManager{
    
    //MARK: - change group name locally
    public func changeGroupName(conversationId : String,conversationTitle : String){
        if let localRealm = localRealm {
            let taskToUpdate = localRealm.objects(ConversationDB.self).filter(NSPredicate(format: "conversationId == %@  AND isDelete = %d", (conversationId), false))
            if !taskToUpdate.isEmpty {
                try! localRealm.write {
                    taskToUpdate.first?.conversationTitle = conversationTitle
                    self.getAllConversations()
                }
            }
        }
    }
    
    //MARK: - change group icon/image locally
    public func changeGroupIcon(conversationId : String,conversationIcon : String){
        if let localRealm = localRealm {
            let taskToUpdate = localRealm.objects(ConversationDB.self).filter(NSPredicate(format: "conversationId == %@  AND isDelete = %d", (conversationId), false))
            if !taskToUpdate.isEmpty {
                try! localRealm.write {
                    taskToUpdate.first?.conversationImageUrl = conversationIcon
                    self.getAllConversations()
                }
            }
        }
    }
    
    //MARK: - get members count
    public func getMemberCount(convId:String) -> Int {
        if let localRealm = localRealm {
            let taskToUpdate = localRealm.objects(ConversationDB.self).filter(NSPredicate(format: "conversationId == %@", (convId)))
            if !taskToUpdate.isEmpty {
                return taskToUpdate.first?.membersCount ?? 0
            }
        }
        return -1
    }
    
    //MARK: - update member count
    public func updateMemberCount(convId: String,inc:Bool,dec:Bool,count:Int) {
          if let localRealm = localRealm {
              do {
                  let listToUpdate = localRealm.objects(ConversationDB.self).filter(NSPredicate(format: "conversationId == %@  AND isDelete = %d", convId, false))
                  
                  guard !listToUpdate.isEmpty else { return }
                  try localRealm.write {
                      if inc {
                          listToUpdate.first?.membersCount = (listToUpdate.first?.membersCount ?? 0) + 1
                      }else if dec {
                          listToUpdate.first?.membersCount = (listToUpdate.first?.membersCount ?? 0) - 1
                      }else {
                          listToUpdate.first?.membersCount = count
                      }
                  }
              } catch {
              }
          }
      }
}
