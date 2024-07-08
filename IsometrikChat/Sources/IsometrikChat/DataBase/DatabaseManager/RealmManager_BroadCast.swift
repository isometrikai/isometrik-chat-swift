//
//  RealmManager_BroadCast.swift
//  ISMChatSdk
//
//  Created by Rasika on 10/06/24.
//

import Foundation
import RealmSwift


extension RealmManager{
    
    //MARK: - get broadcast list count
    func getBroadCastsCount() -> Int {
        broadcasts.count
    }
    
    //MARK: - get all broadcast
    func getBroadCasts() -> [BroadCastListDB] {
        broadcasts
    }
    
    //MARK: - manage broadcast list, if already there update else add.
    func manageBroadCastList(arr: [ISMChat_BroadCastDetail]) {
        if let localRealm = localRealm {
            for obj in arr {
                let taskToUpdate = localRealm.objects(BroadCastListDB.self).filter(NSPredicate(format: "groupcastId == %@", (obj.groupcastId ?? "")))
                if taskToUpdate.isEmpty {
                    addBroadCasts(obj: [obj])
                }else {
                    if let objID = taskToUpdate.first?.id {
                        if taskToUpdate.first?.isDelete == false {
                            updateBroadCast(obj: obj)
                        }
                    }
                }
            }
        }
    }
    
    //MARK: - update broadcast if already there in local db
    func updateBroadCast(obj: ISMChat_BroadCastDetail) {
        if let localRealm = localRealm {
            do {
                let listToUpdate = localRealm.objects(BroadCastListDB.self).filter(NSPredicate(format: "groupcastId == %@  AND isDelete = %d", (obj.groupcastId ?? ""), false))
                
                guard !listToUpdate.isEmpty else { return }
                try localRealm.write {
                    
                    listToUpdate.first?.membersCount = obj.membersCount
                    listToUpdate.first?.groupcastTitle = obj.groupcastTitle
                    listToUpdate.first?.groupcastImageUrl = obj.groupcastImageUrl
                    listToUpdate.first?.groupcastId = obj.groupcastId ?? ""
                    listToUpdate.first?.customType = obj.customType
                    listToUpdate.first?.createdBy = obj.createdBy
                    listToUpdate.first?.createdAt = obj.createdAt
                    
                    var memberDetails = List<BroadCastMemberDetailDB>()
                    
                    if let members = obj.metaData?.membersDetail {
                        for member in members {
                            let memberDetail = BroadCastMemberDetailDB()
                            memberDetail.memberId = member.memberId
                            memberDetail.memberName = member.memberName
                            memberDetails.append(memberDetail)
                        }
                    }
                    
                    if listToUpdate.first?.metaData == nil {
                        listToUpdate.first?.metaData = BroadCastMetaDataDB()
                    }
                    
                    listToUpdate.first?.metaData?.membersDetail.removeAll()
                    listToUpdate.first?.metaData?.membersDetail.append(objectsIn: memberDetails)
                    getAllBroadCasts()
                }
            }catch {
                print("Error updating task \(obj.id) to Realm: \(error)")
            }
        }
    }
    
    //MARK: - add broadcast if not locally present
    func addBroadCasts(obj: [ISMChat_BroadCastDetail]) {
        if let localRealm = localRealm {
            do {
                try localRealm.write {
                    for value in obj {
                        
                        let obj = BroadCastListDB()
                        obj.membersCount = value.membersCount
                        obj.groupcastTitle = value.groupcastTitle
                        obj.groupcastImageUrl = value.groupcastImageUrl
                        obj.groupcastId = value.groupcastId ?? ""
                        obj.customType = value.customType
                        obj.createdBy = value.createdBy
                        obj.createdAt = value.createdAt
                        
                        var memberDetails = List<BroadCastMemberDetailDB>()
                        
                        if let members = value.metaData?.membersDetail {
                            for member in members {
                                let memberDetail = BroadCastMemberDetailDB()
                                memberDetail.memberId = member.memberId
                                memberDetail.memberName = member.memberName
                                memberDetails.append(memberDetail)
                            }
                        }
                        
                        if obj.metaData == nil {
                            obj.metaData = BroadCastMetaDataDB()
                        }
                        obj.metaData?.membersDetail.append(objectsIn: memberDetails)
                        localRealm.add(obj)
                        
                    }
                    getAllBroadCasts()
                }
            }catch {
                print("Error adding task to Realm: \(error)")
            }
        }
    }
    
    // MARK: - delete particular broadcast from broadcast list
    func deleteBroadCast(groupcastId: String) {
        if let localRealm = localRealm {
            do {
                let taskToDelete = localRealm.objects(BroadCastListDB.self).filter(NSPredicate(format: "groupcastId == %@", groupcastId))
                guard !taskToDelete.isEmpty else { return }
                try localRealm.write {
                    taskToDelete.first?.isDelete = true
                    getAllBroadCasts()
                }
            } catch {
                print("Error deleting task \(groupcastId) to Realm: \(error)")
            }
        }
    }
    
    //MARK: - delete all message in broadcast
    func deleteMessagesThroughGroupCastId(groupcastId: String)  {
        if let localRealm = localRealm {
            let taskToUpdate = localRealm.objects(MessagesDB.self).filter(NSPredicate(format: "groupcastId == %@", (groupcastId )))
            if !taskToUpdate.isEmpty {
                try! localRealm.write {
                    for x in taskToUpdate{
                        x.isDelete = true
                    }
                }
            }
        }
    }
    
    //MARK: - get all local broadcasts
    func getAllBroadCasts() {
        if let localRealm = localRealm {
            broadcasts =  Array(localRealm.objects(BroadCastListDB.self).where{$0.isDelete == false })
        }
    }
    
    
    func deleteBroadCastMessages(groupcastId : String,messageId : String)  {
        if let localRealm = localRealm {
            do {
                let taskToDelete = localRealm.objects(MessagesDB.self).filter(NSPredicate(format: "groupcastId == %@ AND messageId = %@ AND conversationId != groupcastId", groupcastId,messageId))
                guard !taskToDelete.isEmpty else { return }
                try localRealm.write {
                    taskToDelete.first?.deletedMessage = true
                }
            } catch {
                //                print("Error deleting task \(convID) to Realm: \(error)")
            }
        }
    }
    
}
