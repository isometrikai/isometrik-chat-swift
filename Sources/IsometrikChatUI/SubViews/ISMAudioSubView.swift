//
//  ISMAudioSubView.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 23/05/23.
//

import SwiftUI
import AVFoundation
import AVKit
import IsometrikChat

/// A SwiftUI view that displays audio message in message List
/// This view is used as a subview in the message list to play and pause audio
struct ISMAudioSubView: View {
    
    //MARK:  - PROPERTIES
    
    /// View model handling audio playback and sound sample visualization
    @StateObject private var audioVM: AudioPlayViewModel
    
    /// Reference to previously playing audio to handle stopping when new audio starts
    @Binding private var previousAudioRef: AudioPlayViewModel?
    
    /// Converts raw audio level to normalized height for visualization bars
    /// - Parameter level: Raw audio level from samples
    /// - Returns: Normalized CGFloat value between 0.2 and 40
    private func normalizeSoundLevel(level: Float) -> CGFloat {
        let level = max(0.2, CGFloat(level) + 70) / 2 // between 0.1 and 35
        return CGFloat(level * (40/35))
    }
    
    /// Indicates if message is received (true) or sent (false)
    private var isReceived : Bool
    
    /// Timestamp when message was sent
    private var sentAt : Double
    
    /// Name of message sender
    private var senderName : String
    
    /// URL for sender's profile image
    private var senderImageUrl : String
    
    /// Current delivery status of message (Clock, SingleTick, DoubleTick, BlueTick)
    private var messageDeliveredType : ISMChatMessageStatus = .Clock
    
    /// Global UI appearance configuration
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    
    init(audio: String,
         sentAt : Double,
         senderName : String,
         senderImageUrl : String,
         isReceived : Bool,
         messageDeliveredType : ISMChatMessageStatus,
         previousAudioRef: Binding<AudioPlayViewModel?>
    ) {
        _audioVM = StateObject(wrappedValue: AudioPlayViewModel(
            url: URL(string: audio) ?? URL(fileURLWithPath: ""),
            sampels_count: 25,
            defaultAudioBarColor: ISMChatSdkUI.getInstance().getAppAppearance().appearance.colorPalette.audioBarDefault,
            audioBarColorWhilePlaying: ISMChatSdkUI.getInstance().getAppAppearance().appearance.colorPalette.audioBarWhilePlaying))
        self.sentAt = sentAt
        self.senderName = senderName
        self.senderImageUrl = senderImageUrl
        self.isReceived = isReceived
        self.messageDeliveredType = messageDeliveredType
        _previousAudioRef = previousAudioRef
    }
    
    //MARK:  - LIFECYCLE
    var body: some View {
        VStack( alignment: .leading ) {
            LazyHStack(alignment: .center, spacing: 10) {
                //image
                if ISMChatSdkUI.getInstance().getChatProperties().hideUserProfileImageFromAudioMessage == false{
                    ZStack(alignment: .bottomTrailing){
                        UserAvatarView(avatar: senderImageUrl,
                                       showOnlineIndicator: false,
                                       size: CGSize(width: 40, height: 40),
                                       userName: senderName,
                                       font: .regular(size: 14))
                        Image("audio_mic")
                            .resizable()
                            .frame(width: 14, height: 14)
                    }
                }
                
                
                Button {
                    DispatchQueue.main.async {
                        if audioVM.isPlaying {
                            audioVM.pauseAudio()
                        } else {
                            
                            if let previousAudioRef {
                                previousAudioRef.pauseAudio()
                                previousAudioRef.removeAudio()
                            }
                            
                            previousAudioRef = audioVM
                            
                            audioVM.playAudio()
                        }
                    }
                } label: {
                    if !(audioVM.isPlaying) {
                        appearance.images.audioPlayIcon
                            .resizable()
                            .frame(width: 16, height: 16)
                    }else{
                        appearance.images.audioPauseIcon
                            .resizable()
                            .frame(width: 16, height: 16)
                    }
                }//:BUTTON
                .padding(.leading,ISMChatSdkUI.getInstance().getChatProperties().hideUserProfileImageFromAudioMessage == true ? 10 : 0)
                
                HStack(alignment: .center, spacing: 2) {
                    if audioVM.soundSamples.isEmpty {
                        ProgressView()
                    } else {
                        ForEach(audioVM.soundSamples, id: \.self) { model in
                            BarView(value: self.normalizeSoundLevel(level: model.magnitude), color: model.color)
                        }
                    }
                }
                
            }//:HSTACK
            .padding(.vertical,ISMChatSdkUI.getInstance().getChatProperties().hideUserProfileImageFromAudioMessage == true ? 15 : 0)
            
            
            HStack{
                Spacer().frame(width: 45)
                Text(formatTime(audioVM.isPlaying ? audioVM.currentTime : audioVM.totalDuration))
                    .font(appearance.fonts.messageListMessageTime)
                    .foregroundColor(isReceived ? appearance.colorPalette.messageListMessageTimeReceived :  appearance.colorPalette.messageListMessageTimeSend)
                    .onAppear(perform: {
                        audioVM.count_duration { _ in
                            // Start playing audio here if needed
                        }
                    })
                    .onReceive(NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime, object: audioVM.player.currentItem), perform: { _ in
                        audioVM.isPlaying = false
                    })
                
                Spacer()
                if appearance.timeInsideBubble == true{
                    dateAndStatusView(onImage: false)
                }
            }
        }//:VSTACK
        .frame(width:  ISMChatSdkUI.getInstance().getChatProperties().hideUserProfileImageFromAudioMessage == false ? 190 : 150)
    }
    
    /// Formats time interval into MM:SS string format
    /// - Parameter time: Time interval in seconds
    /// - Returns: Formatted time string
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time / 60)
        let seconds = Int(time.truncatingRemainder(dividingBy: 60))
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    /// Generates view for timestamp and message delivery status
    /// - Parameter onImage: Whether status is displayed on an image
    /// - Returns: Status indicator view
    func dateAndStatusView(onImage : Bool) -> some View{
        HStack(alignment: .center,spacing: 3){
            Text(sentAt.datetotime())
                .font(appearance.fonts.messageListMessageTime)
                .foregroundColor(isReceived ? appearance.colorPalette.messageListMessageTimeReceived :  appearance.colorPalette.messageListMessageTimeSend)
            if !isReceived{
                switch self.messageDeliveredType{
                case .BlueTick:
                    appearance.images.messageRead
                        .resizable()
                        .frame(width: appearance.imagesSize.messageRead.width, height: appearance.imagesSize.messageRead.height)
                case .DoubleTick:
                    appearance.images.messageDelivered
                        .resizable()
                        .frame(width: appearance.imagesSize.messageDelivered.width, height: appearance.imagesSize.messageDelivered.height)
                case .SingleTick:
                    appearance.images.messageSent
                        .resizable()
                        .frame(width: appearance.imagesSize.messageSend.width, height: appearance.imagesSize.messageSend.height)
                case .Clock:
                    appearance.images.messagePending
                        .resizable()
                        .frame(width: appearance.imagesSize.messagePending.width, height: appearance.imagesSize.messagePending.height)
                }
            }
        }//:HStack
    }
    
    struct BarView: View {
        let value: CGFloat
        var color: Color = Color.audiobar
        
        var body: some View {
            ZStack {
                Rectangle()
                    .fill(color)
                    .cornerRadius(10)
                    .frame(width: 2, height: value)
            }
        }
    }
}
