//
//  BroadCastListModel.swift
//  IsometrikChat
//
//  Created by Rasika Bharati on 26/02/25.
//
import SwiftData
import Foundation


@Model
public class ISMChatBroadCastListDB{
    public var groupcastId: String?
    public var membersCount : Int?
    public var groupcastTitle : String?
    public var groupcastImageUrl : String?
    public var customType : String?
    public var createdBy : String?
    public var createdAt : Double?
    public var metaData : ISMChatBroadCastMetaDataDB?
    public var isDelete : Bool = false
    public var updatedAt : Int?
    public init(groupcastId: String? = nil, membersCount: Int? = nil, groupcastTitle: String? = nil, groupcastImageUrl: String? = nil, customType: String? = nil, createdBy: String? = nil, createdAt: Double? = nil, metaData: ISMChatBroadCastMetaDataDB? = nil, isDelete: Bool, updatedAt: Int? = nil) {
        self.groupcastId = groupcastId
        self.membersCount = membersCount
        self.groupcastTitle = groupcastTitle
        self.groupcastImageUrl = groupcastImageUrl
        self.customType = customType
        self.createdBy = createdBy
        self.createdAt = createdAt
        self.metaData = metaData
        self.isDelete = isDelete
        self.updatedAt = updatedAt
    }
}

@Model
public class ISMChatBroadCastMetaDataDB  {
    public var membersDetail : [ISMChatBroadCastMemberDetailDB]
    public init(membersDetail: [ISMChatBroadCastMemberDetailDB]) {
        self.membersDetail = membersDetail
    }
}

@Model
public class ISMChatBroadCastMemberDetailDB{
    public var memberId : String?
    public var memberName : String?
    public init(memberId: String? = nil, memberName: String? = nil) {
        self.memberId = memberId
        self.memberName = memberName
    }
}
