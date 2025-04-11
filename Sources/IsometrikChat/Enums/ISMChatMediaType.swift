//
//  ISMMediaType.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 03/04/23.
//

import Foundation

public enum ISMChatMediaType : CaseIterable{
    case Text
    case Image
    case File
    case Video
    case Voice
    case Location
    case sticker
    case gif
    case Contact
    case ReplyText
    case Block
    case Unblock
    case VideoCall
    case AudioCall
    case GroupCall
    case Post
    case Product
    case ProductLink
    case SocialLink
    case CollectionLink
    case PaymentRequest
    case DineInInvite
    case DineInStatus
    case ProfileShare
    //
    case OfferSent
    case CounterOffer
    case EditOffer
    case AcceptOrder
    case CancelDeal
    case CancelOffer
    case BuyDirectRequest
    case AcceptBusyDirectRequest
    case CancelBuyDirectRequest
    case RejectBuyDirectRequest
    case PaymentEscrowed
    case DealComplete
    //
    case cheaper
    case cheaperCancelOffer
    case cheaperAcceptOffer
    case cheaperCounterOffer
    public var value : String{
        switch self {
        case .Text:
            return "AttachmentMessage:Text"
        case .Image:
            return "AttachmentMessage:Image"
        case .File:
            return "AttachmentMessage:File"
        case .Video:
            return "AttachmentMessage:Video"
        case .Voice:
            return "AttachmentMessage:Audio"
        case .Location:
            return "AttachmentMessage:Location"
        case .sticker:
            return "AttachmentMessage:Sticker"
        case .gif:
            return "AttachmentMessage:Gif"
        case .ReplyText:
            return "AttachmentMessage:Reply"
        case .Block:
            return "block"
        case .Unblock:
            return "unblock"
        case .Contact:
            return "AttachmentMessage:Contact"
        case .VideoCall:
            return "VideoCall"
        case .AudioCall:
            return "AudioCall"
        case .GroupCall:
            return "GroupCall"
        case .Post:
            return "AttachmentMessage:Post"
        case .Product:
            return "AttachmentMessage:Product"
        case .ProductLink:
            return "AttachmentMessage:ProductLink"
        case .SocialLink:
            return "AttachmentMessage:SocialLink"
        case .CollectionLink:
            return "AttachmentMessage:CollectionLink"
        case .PaymentRequest:
            return "AttachmentMessage:Payment Request"
        case .DineInInvite:
            return "AttachmentMessage:DineInInvite"
        case .DineInStatus:
            return "AttachmentMessage:DineInInviteStatus"
        case .ProfileShare:
            return "AttachmentMessage:ProfileShare"
        case .OfferSent:
            return "OFFER_SENT"
        case .CounterOffer:
            return "COUNTER_OFFER"
        case .EditOffer:
            return "EDIT_OFFER"
        case .AcceptOrder:
            return "ACCEPT_OFFER"
        case .CancelDeal:
            return "CANCEL_DEAL"
        case .CancelOffer:
            return "CANCEL_OFFER"
        case .BuyDirectRequest:
            return "BUYDIRECT_REQUEST"
        case .AcceptBusyDirectRequest:
            return "ACCEPT_BUYDIRECT_REQUEST"
        case .CancelBuyDirectRequest:
            return "CANCEL_BUYDIRECT_REQUEST"
        case .RejectBuyDirectRequest:
            return "REJECT_BUYDIRECT_REQUEST"
        case .PaymentEscrowed:
            return "PAYMENT_ESCROWED"
        case .DealComplete:
            return "DEAL_COMPLETE"
        case .cheaper:
            return "CHEAPER"
        case .cheaperCancelOffer:
            return "CHEAPER_CANCEL_OFFER"
        case .cheaperAcceptOffer:
            return "CHEAPER_ACCEPT_OFFER"
        case .cheaperCounterOffer:
            return "CHEAPER_COUNTER_OFFER"
        }
    }
}
