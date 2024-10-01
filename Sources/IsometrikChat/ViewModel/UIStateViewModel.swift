//
//  File.swift
//  
//
//  Created by Rasika Bharati on 09/09/24.
//

import Foundation
import SwiftUI


public class UIStateViewModel: ObservableObject {
    
    @Published public var keyboardFocused = false
    @Published public var showActionSheet = false
    @Published public var showVideoPicker = false
    @Published public var showLocationSharing = false
    @Published public var showSheet = false
    @Published public var shareContact : Bool = false
    @Published public var showScrollToBottomView = false
    @Published public var audioLocked : Bool = false
    @Published public var isShowingRedTimerStart : Bool = false
    
    @Published public var showDeleteMultipleMessage = false
    @Published public var showDeleteActionSheet = false
    @Published public var showforwardMultipleMessage : Bool = false
    @Published public var movetoForwardList : Bool = false
    @Published public var isClicked : Bool = false
    @Published public var uploadMedia : Bool = false
    
    @Published public var audioPermissionCheck :Bool = false
    @Published public var executeRepeatly : Bool = false
    @Published public var otherUserTyping : Bool = false
    
//    @Published public var navigateToBlockUsers = false
    @Published public var navigateToProfile = false
    @Published public var navigateToGroupCastInfo  : Bool = false
    @Published public var showUnblockPopUp : Bool = false
    @Published public var uAreBlock : Bool = false
    
    @Published public var clearThisChat : Bool = false
    @Published public var blockThisChat : Bool = false
    @Published public var showingNoInternetAlert = false
    @Published public var onLoad : Bool = false
    
    @Published public var messageCopied : Bool = false
    @Published public var executeRepeatlyForOfflineMessage : Bool = false
    @Published public var navigateToLocation = false
    @Published public var showMentionList : Bool = false
    @Published public var showGifPicker : Bool = false
    
    @Published public var audioCallToUser : Bool = false
    @Published public var videoCallToUser : Bool = false
    @Published public var showCallPopUp : Bool = false
    @Published public var isAnimating = false

    
    @Published public var navigateToImageEditor : Bool = false
    @Published public var sendMedia : Bool = false
    @Published public var navigateToAddParticipantsInGroupViaDelegate : Bool = false
    
    @Published public var navigateToMediaSlider : Bool = false
    @Published public var navigateToUserProfile : Bool = false
    
    public init() {}
}
