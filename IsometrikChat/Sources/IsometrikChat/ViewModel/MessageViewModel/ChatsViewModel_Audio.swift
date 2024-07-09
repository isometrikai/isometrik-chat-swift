//
//  ChatsViewModel_Audio.swift
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
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
        } catch {
            ISMChat_Helper.print("Cannot setup the Recording")
        }
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = path.appendingPathComponent("\(Date()).m4a")
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        do {
            audioRecorder = try AVAudioRecorder(url: fileName, settings: settings)
            audioRecorder.prepareToRecord()
            audioRecorder.record()
            isRecording = true
            
            timerCount = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (value) in
                self.countSec += 1
                self.timerValue = ISMChat_Helper().covertSecToMinAndHour(seconds: self.countSec)
            })
        } catch {
            ISMChat_Helper.print("Failed to Setup the Recording")
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
            recordingsList.append(ISMChat_Recording(fileURL : i, createdAt: ISMChat_Helper().getFileDate(for: i), isPlaying: false))
        }
        recordingsList.sort(by: { $0.createdAt.compare($1.createdAt) == .orderedDescending})
        completion(recordingsList.first?.fileURL)
    }
}
