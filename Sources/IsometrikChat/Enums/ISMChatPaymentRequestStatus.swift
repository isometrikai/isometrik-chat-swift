//
//  ISMChatPaymentRequestStatus.swift
//  IsometrikChat
//
//  Created by Rasika Bharati on 23/12/24.
//


public enum ISMChatPaymentRequestStatus: Int {
    case ActiveRequest = 0
    case Accepted = 1
    case Rejected = 2
    case Expired = 3
    case Cancelled = 4
    case PayedByOther = 5
    case Rescheduled
}
