//
//  AudioService.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 15/05/23.
//

import Foundation
import Combine
import AVFoundation
import SwiftUI

public protocol ServiceProtocol {
    func buffer(url: URL,audioBarColor : Color, samplesCount: Int, completion: @escaping([ISMChatAudioPreviewModel]) -> ())
}


public class Service {
    static public let shared: ServiceProtocol = Service()
    public init() { }
}

extension Service: ServiceProtocol {
    public func buffer(url: URL,audioBarColor : Color, samplesCount: Int, completion: @escaping([ISMChatAudioPreviewModel]) -> ()) {
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                var cur_url = url
                if url.absoluteString.hasPrefix("https://") {
                    let data = try Data(contentsOf: url)
                    
                    let directory = FileManager.default.temporaryDirectory
                    let fileName = "chunk.m4a)"
                    cur_url = directory.appendingPathComponent(fileName)
                    
                    try data.write(to: cur_url)
                }
                
                let file = try AVAudioFile(forReading: cur_url)
                if let format = AVAudioFormat(commonFormat: .pcmFormatFloat32,
                                              sampleRate: file.fileFormat.sampleRate,
                                              channels: file.fileFormat.channelCount, interleaved: false),
                   let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(file.length)) {
                    
                    try file.read(into: buf)
                    guard let floatChannelData = buf.floatChannelData else { return }
                    let frameLength = Int(buf.frameLength)
                    
                    let samples = Array(UnsafeBufferPointer(start:floatChannelData[0], count:frameLength))
                    
                    var result = [ISMChatAudioPreviewModel]()
                    
                    let chunked = samples.chunked(into: samples.count / samplesCount)
                    for row in chunked {
                        var accumulator: Float = 0
                        let newRow = row.map{ $0 * $0 }
                        accumulator = newRow.reduce(0, +)
                        let power: Float = accumulator / Float(row.count)
                        let decibles = 10 * log10f(power)
                        
                        result.append(ISMChatAudioPreviewModel(magnitude: decibles, color: audioBarColor))
                        
                    }
                    DispatchQueue.main.async {
                        completion(result)
                    }
                }
            } catch {
                ISMChatHelper.print("Audio Error: \(error)")
            }
        }
    }
}


