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

struct ISMAudioSubView: View {
    
    //MARK:  - PROPERTIES

    
    @StateObject private var audioVM: AudioPlayViewModel
    @Binding private var previousAudioRef: AudioPlayViewModel?
    
    private func normalizeSoundLevel(level: Float) -> CGFloat {
        let level = max(0.2, CGFloat(level) + 70) / 2 // between 0.1 and 35
        return CGFloat(level * (40/35))
    }
    private var message : MessagesDB
    private var isReceived : Bool
    private var messageDeliveredType : ISMChat_MessageStatus = .Clock
    @State var themeImage = ISMChatSdk.getInstance().getAppAppearance().appearance.images
    
    init(audio: String,
         message : MessagesDB,
         isReceived : Bool,
         messageDeliveredType : ISMChat_MessageStatus,
         previousAudioRef: Binding<AudioPlayViewModel?>
    ) {
        _audioVM = StateObject(wrappedValue: AudioPlayViewModel(url: URL(string: audio) ?? URL(fileURLWithPath: ""), sampels_count: 25))
        self.message = message
        self.isReceived = isReceived
        self.messageDeliveredType = messageDeliveredType
        _previousAudioRef = previousAudioRef
    }
    
    //MARK:  - LIFECYCLE
    var body: some View {
        VStack( alignment: .leading ) {
            LazyHStack(alignment: .center, spacing: 10) {
               //image
                ZStack(alignment: .bottomTrailing){
                    UserAvatarView(avatar: message.senderInfo?.userProfileImageUrl ?? "",
                                   showOnlineIndicator: false,
                                   size: CGSize(width: 40, height: 40),
                                   userName: message.senderInfo?.userName ?? "",
                                   font: .regular(size: 14))
                    Image("audio_mic")
                        .resizable()
                        .frame(width: 14, height: 14)
                }
                
                // button and timer
                VStack(alignment: .center,spacing: 14){
                    Button {
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
                    } label: {
                        Image(!(audioVM.isPlaying) ? "Audio_play" : "Audio_pause" )
                            .resizable()
                            .frame(width: 16, height: 16)
                    }//:BUTTON
                }
                    HStack(alignment: .center, spacing: 2) {
                        if audioVM.soundSamples.isEmpty {
                            ProgressView()
                        } else {
                            ForEach(audioVM.soundSamples, id: \.self) { model in
                                BarView(value: self.normalizeSoundLevel(level: model.magnitude), color: model.color)
                                    .padding(.horizontal,1)
                            }
                        }
                    }
                
            }//:HSTACK
            
            
            HStack{
                Spacer().frame(width: 45)
                Text(formatTime(audioVM.isPlaying ? audioVM.currentTime : audioVM.totalDuration))
                    .font(Font.regular(size: 12))
                    .foregroundColor(Color.onboardingPlaceholder)
                    .onAppear(perform: {
                        audioVM.count_duration { _ in
                            // Start playing audio here if needed
                        }
                    })
                    .onReceive(NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime, object: audioVM.player.currentItem), perform: { _ in
                        audioVM.isPlaying = false
                    })
                
                Spacer().frame(width: 100)
                dateAndStatusView(onImage: false)
            }
            
        }//:VSTACK
//        .frame(minHeight: 0, maxHeight: 50)
    }
    
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time / 60)
        let seconds = Int(time.truncatingRemainder(dividingBy: 60))
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func dateAndStatusView(onImage : Bool) -> some View{
        HStack(alignment: .center,spacing: 3){
            Text(message.sentAt.datetotime())
                .font(Font.regular(size: 12))
                .foregroundColor(onImage ? Color.white : Color.onboardingPlaceholder)
            if !isReceived && !message.deletedMessage{
                switch self.messageDeliveredType{
                case .BlueTick:
                    themeImage.messageRead
                        .resizable()
                        .frame(width: 15, height: 9)
                case .DoubleTick:
                    themeImage.messageDelivered
                        .resizable()
                        .frame(width: 15, height: 9)
                case .SingleTick:
                    themeImage.messageSent
                        .resizable()
                        .frame(width: 11, height: 9)
                case .Clock:
                    themeImage.messagePending
                        .resizable()
                        .frame(width: 9, height: 9)
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
                    .frame(width: 2, height: value/2)
            }
        }
    }
}
