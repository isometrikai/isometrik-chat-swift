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
            content
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap(attachment)
        }
    }

    var content: some View {
        AsyncImageView(url: attachment.thumbnailUrl)
    }
}

struct AsyncImageView: View {

  
    let url: String

    var body: some View {
        ISMChatImageCahcingManger.viewImage(url: url)
    }
}
