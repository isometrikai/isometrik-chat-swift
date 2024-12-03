//
//  ChatsViewModelAudio.swift
//  ISMChatSdk
//
//  Created by Rasika on 12/06/24.
//

import Foundation
import AVFoundation
import AVKit


extension ChatsViewModel{
    
    //MARK: - start recording audio
    public func startRecording() {
        let recordingSession = AVAudioSession.sharedInstance()
        do {
            // Configure audio session for recording
            try recordingSession.setCategory(.record, mode: .default, options: .defaultToSpeaker)
            try recordingSession.setActive(true)
        } catch {
            ISMChatHelper.print("Cannot setup the Recording Session")
            return
        }
        
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = path.appendingPathComponent("Recording_\(Date().timeIntervalSince1970).m4a")
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100, // Higher sample rate
            AVNumberOfChannelsKey: 2, // Stereo recording
            AVEncoderBitRateKey: 128000, // High bitrate
            AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: fileName, settings: settings)
            audioRecorder.prepareToRecord()
            audioRecorder.record()
            isRecording = true
            
            timerCount = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (value) in
                self.countSec += 1
                self.timerValue = ISMChatHelper().covertSecToMinAndHour(seconds: self.countSec)
            })
        } catch {
            ISMChatHelper.print("Failed to Setup the Recording")
        }
    }
    
    //MARK: - stop recording audio
    public func stopRecording(completion:@escaping(URL?)->()){
        if audioRecorder != nil{
            audioRecorder.stop()
            isRecording = false
            self.countSec = 0
            timerCount!.invalidate()
            fetchAllRecording { url in
                completion(url)
            }
        }
    }
    
    //MARK: - fetch all recording audio
    public func fetchAllRecording(completion:@escaping(URL?)->()){
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let directoryContents = try! FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil)
        for i in directoryContents {
            recordingsList.append(ISMChatRecording(fileURL : i, createdAt: ISMChatHelper().getFileDate(for: i), isPlaying: false))
        }
        recordingsList.sort(by: { $0.createdAt.compare($1.createdAt) == .orderedDescending})
        completion(recordingsList.first?.fileURL)
    }
}
