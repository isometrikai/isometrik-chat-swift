//
//  ISMMessageView+MediaPicker.swift
//  ISMChatSdk
//
//  Created by Rasika on 15/04/24.
//

import Foundation
import MediaPicker
import IsometrikChat

 extension ISMMessageView{
    //MARK: - IMPOTER
    func handleMediaImporterResult(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            DispatchQueue.main.async {
                if videoSelectedFromPicker.count == 0{
                    chatViewModel.isBusy = true
                    let mediaUploads: [ISMMediaUpload] = urls.map { url in
                        if ISMChatHelper.isVideo(media: url) == true {
                            return ISMMediaUpload(url: url, caption: "", isVideo: true)
                        } else {
                            return ISMMediaUpload(url: url, caption: "", isVideo: false)
                        }
                    }
                    videoSelectedFromPicker.append(contentsOf: mediaUploads)
                    if urls.count == videoSelectedFromPicker.count{
                        stateViewModel.navigateToImageEditor.toggle()
                    }
                }
            }
        case .failure(let error):
            fatalError("No Data: \(error)")
        }
    }
}
