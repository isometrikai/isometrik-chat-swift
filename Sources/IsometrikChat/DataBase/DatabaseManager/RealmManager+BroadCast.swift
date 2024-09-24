//
//  RealmManagerBroadCast.swift
//  ISMChatSdk
//
//  Created by Rasika on 10/06/24.
//

import Foundation
import RealmSwift


extension RealmManager{
    
    //MARK: - get broadcast list count
    public func getBroadCastsCount() -> Int {
        broadcasts.count
    }
    
    //MARK: - get all broadcast
    public func getBroadCasts() -> [BroadCastListDB] {
        broadcasts = broadcasts.sorted(by: { lhsData, rhsData in
            Int(lhsData.updatedAt ?? 0) > Int(rhsData.updatedAt ?? 0)
        })
        return broadcasts
    }
    
    //MARK: - manage broadcast list, if already there update else add.
    public func manageBroadCastList(arr: [ISMChatBroadCastDetail]) {
        if let localRealm = localRealm {
            for obj in arr {
                let taskToUpdate = localRealm.objects(BroadCastListDB.self).filter(NSPredicate(format: "groupcastId == %@", (obj.groupcastId ?? "")))
                if taskToUpdate.isEmpty {
                    addBroadCasts(obj: [obj])
                }else {
                    if (taskToUpdate.first?.id) != nil {
                        if taskToUpdate.first?.isDelete == false {
                            updateBroadCast(obj: obj)
                        }
                    }
                }
            }
        }
    }
    
    //MARK: - update broadcast if already there in local db
    public func updateBroadCast(obj: ISMChatBroadCastDetail) {
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
                    listToUpdate.first?.updatedAt = obj.updatedAt
                    
                    let memberDetails = List<BroadCastMemberDetailDB>()
                    
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
                    getAllLocalBroadCasts()
                }
            }catch {
                print("Error updating task \(obj.id) to Realm: \(error)")
            }
        }
    }
    
    //MARK: - add broadcast if not locally present
    public func addBroadCasts(obj: [ISMChatBroadCastDetail]) {
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
                        obj.updatedAt = value.updatedAt
                        
                        let memberDetails = List<BroadCastMemberDetailDB>()
                        
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
                    getAllLocalBroadCasts()
                }
            }catch {
                print("Error adding task to Realm: \(error)")
            }
        }
    }
    
    // MARK: - delete particular broadcast from broadcast list
    public func deleteBroadCast(groupcastId: String) {
        if let localRealm = localRealm {
            do {
                let taskToDelete = localRealm.objects(BroadCastListDB.self).filter(NSPredicate(format: "groupcastId == %@", groupcastId))
                guard !taskToDelete.isEmpty else { return }
                try localRealm.write {
                    taskToDelete.first?.isDelete = true
                    getAllLocalBroadCasts()
                }
            } catch {
                print("Error deleting task \(groupcastId) to Realm: \(error)")
            }
        }
    }
    
    //MARK: - delete all message in broadcast
    public func deleteMessagesThroughGroupCastId(groupcastId: String)  {
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
    public func getAllLocalBroadCasts() {
        if let localRealm = localRealm {
            broadcasts =  Array(localRealm.objects(BroadCastListDB.self).where{$0.isDelete == false })
            broadcasts = broadcasts.sorted(by: { lhsData, rhsData in
                Int(lhsData.updatedAt ?? 0) > Int(rhsData.updatedAt ?? 0)
            })
            storeBroadcasts = broadcasts
        }
    }
    
    
    public func deleteBroadCastMessages(groupcastId : String,messageId : String)  {
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
