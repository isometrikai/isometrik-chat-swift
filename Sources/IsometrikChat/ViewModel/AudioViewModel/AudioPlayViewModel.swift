//
//  AudioPlayViewModel.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 23/05/23.
//

import Foundation
import AVKit
import SwiftUI
import AVFoundation
import Combine

public class AudioPlayViewModel: ObservableObject {
    
    //MARK:  - PROPERTIES
    public var timer: Timer?
    @Published public var isPlaying: Bool = false
    @Published public var soundSamples = [ISMChatAudioPreviewModel]()
    public let sample_count: Int
    public var index = 0
    public let url: URL
    public var dataManager: ServiceProtocol
    public var defaultAudioBarColor : Color
    public var audioBarColorWhilePlaying : Color
    @Published public var player: AVPlayer!
    @Published public var session: AVAudioSession!
    @Published public var currentTime: TimeInterval = 0.0
    @Published public var totalDuration: TimeInterval = 0.2
    
    public init(url: URL, sampels_count: Int, dataManager: ServiceProtocol = Service.shared,defaultAudioBarColor: Color, audioBarColorWhilePlaying : Color) {
        self.url = url
        self.sample_count = sampels_count
        self.dataManager = dataManager
        self.defaultAudioBarColor = defaultAudioBarColor
        self.audioBarColorWhilePlaying = audioBarColorWhilePlaying
        visualizeAudio()
        do {
            session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord)
            try session.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        } catch {
            ISMChatHelper.print(error.localizedDescription)
        }
        player = AVPlayer(url: self.url)
    }
    
    func startTimer() {
        count_duration { duration in
            let time_interval = duration / Double(self.sample_count)
            
            self.timer = Timer.scheduledTimer(withTimeInterval: time_interval, repeats: true, block: { (timer) in
                if self.index < self.soundSamples.count {
//                    withAnimation(Animation.linear) {
                    self.soundSamples[self.index].color = self.audioBarColorWhilePlaying
//                    }
                    self.index += 1
                    if let currentTime = self.player.currentItem?.currentTime().seconds {
                        self.currentTime = currentTime
                    }
                }
            })
        }
    }

    public func count_duration(completion: @escaping (Float64) -> ()) {
        DispatchQueue.global(qos: .background).async {
            guard let asset = self.player.currentItem?.asset else {
                DispatchQueue.main.async {
                    self.totalDuration = 0.2 // Set initial value
                    completion(0.2)
                }
                return
            }

            // Load the duration asynchronously
            Task {
                do {
                    let duration = try await asset.load(.duration)
                    let seconds = CMTimeGetSeconds(duration)
                    DispatchQueue.main.async {
                        self.totalDuration = seconds
                        completion(seconds)
                    }
                } catch {
                    print("Failed to load duration: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.totalDuration = 0.2 // Set initial value
                        completion(0.2)
                    }
                }
            }
        }
    }

    
    @objc func playerDidFinishPlaying(note: NSNotification) {
        self.player.pause()
        self.player.seek(to: .zero)
        self.timer?.invalidate()
        self.isPlaying = false
        self.index = 0
        self.soundSamples = self.soundSamples.map { tmp -> ISMChatAudioPreviewModel in
            var cur = tmp
            cur.color = self.defaultAudioBarColor
            return cur
        }
        self.currentTime =  0.0
    }
    
    public func playAudio() {
        if isPlaying {
            pauseAudio()
        } else {
            NotificationCenter.default.addObserver(self, selector:#selector(self.playerDidFinishPlaying(note:)),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
            isPlaying.toggle()
            player.play()
            startTimer()
            count_duration { _ in }
        }
    }
    
    public func pauseAudio() {
        player.pause()
        timer?.invalidate()
        self.isPlaying = false
    }
    
    
//    func count_duration(completion: @escaping(Float64) -> ()) {
//        DispatchQueue.global(qos: .background).async {
//            if let duration = self.player.currentItem?.asset.duration {
//                let seconds = CMTimeGetSeconds(duration)
//                DispatchQueue.main.async {
//                    completion(seconds)
//                }
//                return
//            }
//            DispatchQueue.main.async {
//                completion(1)
//            }
//        }
//    }
    
    func visualizeAudio() {
        dataManager.buffer(url: url, audioBarColor: self.defaultAudioBarColor, samplesCount: sample_count) { results in
            self.soundSamples = results
        }
    }
    
    public func removeAudio() {
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            ISMChatHelper.print(error)
        }
    }
}
