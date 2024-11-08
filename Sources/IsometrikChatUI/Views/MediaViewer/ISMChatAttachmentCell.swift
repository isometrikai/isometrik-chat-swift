//
//  SwiftUIView.swift
//  
//
//  Created by Rasika Bharati on 19/09/24.
//

import SwiftUI
import IsometrikChat

struct ISMChatAttachmentCell: View {


    let attachment: MediaDB
    let onTap: (MediaDB) -> Void
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance

    var body: some View {
        Group {
            if ISMChatHelper.isVideoString(media: attachment.mediaUrl) {
                ISMChatImageCahcingManger.viewImage(url: attachment.thumbnailUrl)
            }else if attachment.mediaUrl.contains("gif"){
                ISMChatImageCahcingManger.viewImage(url: attachment.mediaUrl)
            }else{
                ISMChatImageCahcingManger.viewImage(url: attachment.mediaUrl)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap(attachment)
        }
    }
}
