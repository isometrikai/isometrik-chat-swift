//
//  SwiftUIView.swift
//  
//
//  Created by Rasika Bharati on 24/10/24.
//

import SwiftUI
import IsometrikChat


struct ISMAttachmentsGrid: View {
    let maxImages: Int = 4
    private let single: AttachmentDB?
    private let grid: [AttachmentDB]
    private let onlyOne: Bool
    private let hidden: String?
    private let showMoreAttachmentId: String?

    init(attachments: [AttachmentDB]) {
        var toShow = attachments

        // Limit the number of attachments shown to the maxImages
        if toShow.count > maxImages {
            toShow = Array(attachments.prefix(maxImages))
            hidden = "+\(attachments.count - (maxImages - 1))"
            showMoreAttachmentId = attachments[maxImages - 1].mediaId
        } else {
            hidden = nil
            showMoreAttachmentId = nil
        }

        // Check if the attachment count is odd or even
        if toShow.count % 2 == 0 {
            single = nil
            grid = toShow
        } else {
            single = toShow.first
            grid = Array(toShow.dropFirst())
        }

        self.onlyOne = attachments.count == 1
    }

    var body: some View {
        VStack(spacing: 4) {
            // Display a single attachment if present
            if let attachment = single {
                AttachmentCell(attachment: attachment)
                    .frame(width: 204, height: grid.isEmpty ? 200 : 100)
                    .cornerRadius(onlyOne ? 0 : 12)
            }

            // Display grid of attachments
            if !grid.isEmpty {
                ForEach(pair(), id: \.id) { pair in
                    HStack(spacing: 4) {
                        AttachmentCell(attachment: pair.left)
                            .frame(width: 100, height: 100)
                            .clipped()
                            .cornerRadius(12)
                        AttachmentCell(attachment: pair.right)
                            .frame(width: 100, height: 100)
                            .clipped()
                            .overlay {
                                if pair.right.mediaId == showMoreAttachmentId, let hidden = hidden {
                                    ZStack {
                                        RadialGradient(
                                            colors: [
                                                .black.opacity(0.8),
                                                .black.opacity(0.6),
                                            ],
                                            center: .center,
                                            startRadius: 0,
                                            endRadius: 90
                                        )
                                        Text(hidden)
                                            .font(.body)
                                            .bold()
                                            .foregroundColor(.white)
                                    }
                                    .allowsHitTesting(false)
                                }
                            }
                            .cornerRadius(12)
                    }
                }
            }
        }
    }
    
    func pair() -> Array<AttachmentsPair> {
        return stride(from: 0, to: grid.count - 1, by: 2)
            .map { AttachmentsPair(left: grid[$0], right: grid[$0+1]) }
    }
    // Extracted overlay function for hidden attachments
    private func overlayHiddenText(hidden: String) -> some View {
        ZStack {
            Color.black.opacity(0.6)
            Text(hidden)
                .font(.body).bold()
                .foregroundColor(.white)
        }
        .allowsHitTesting(false)
    }
}
struct AttachmentsPair {
    let left: AttachmentDB
    let right: AttachmentDB

    var id: String {
        left.mediaId + "+" + right.mediaId
    }
}

struct AttachmentCell: View {
    let attachment: AttachmentDB

    var body: some View {
        AsyncImageView(url: "https://chatstorage.isometrik.io/5eb3db9ba9252000014f82ff/e1241039-2fef-4830-b927-5bb3424f1764/Users/65eb1515837d050001c3428d_1709905210224.png"  /*attachment.thumbnailUrl*/ )
            .overlay {
                // Display play button overlay if the attachment is a video
                if ISMChatHelper.isVideoString(media: attachment.mediaUrl ?? "") {
                    Image(systemName: "play.circle.fill")
                        .resizable()
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                }
            }
            .contentShape(Rectangle())
    }
}
