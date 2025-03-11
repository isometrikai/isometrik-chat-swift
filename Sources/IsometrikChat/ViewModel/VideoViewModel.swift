//
//  File.swift
//  
//
//  Created by Rasika Bharati on 19/09/24.
//

import Foundation
import AVKit
import Combine

public class ISMChatVideoViewModel: ObservableObject {

    @Published public var attachment: ISMChatMediaDB
    @Published public var player: AVPlayer?

    @Published public var isPlaying = false
    @Published public var isMuted = false

    private var subscriptions = Set<AnyCancellable>()
    @Published public var status: AVPlayer.Status = .unknown

    public init(attachment: ISMChatMediaDB) {
        self.attachment = attachment
    }

    public func onStart() {
        if player == nil ,let url = URL(string: attachment.mediaUrl){
            self.player = AVPlayer(url: url)
            self.player?.publisher(for: \.status)
                .assign(to: &$status)

            NotificationCenter.default.addObserver(self, selector: #selector(finishVideo), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        }
    }

    public func onStop() {
        pauseVideo()
    }

    public func togglePlay() {
        if player?.isPlaying == true {
            pauseVideo()
        } else {
            playVideo()
        }
    }

    public func toggleMute() {
        player?.isMuted.toggle()
        isMuted = player?.isMuted ?? false
    }

    public func playVideo() {
        player?.play()
        isPlaying = player?.isPlaying ?? false
    }

    public func pauseVideo() {
        player?.pause()
        isPlaying = player?.isPlaying ?? false
    }

    @objc public func finishVideo() {
        player?.seek(to: CMTime(seconds: 0, preferredTimescale: 10))
        isPlaying = false
    }
}


extension AVPlayer {
    public var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}
