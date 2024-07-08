//
//  Images.swift
//  ISMChatSdk
//
//  Created by Dheeraj Kumar Sharma on 16/10/23.
//

import UIKit

//public class ISMChat_Images {
//    
//    /// A private internal function that will safely load an image from the bundle or return a circle image as backup
//    /// - Parameter imageName: The required image name to load from the bundle
//    /// - Returns: A UIImage that is either the correct image from the bundle or backup circular image
//    private static func loadImageSafely(with imageName: String) -> UIImage {
//        if let image = UIImage(named: imageName) {
//            return image
//        } else {
//            print(
//                """
//                \(imageName) image has failed to load from the bundle please make sure it's included in your assets folder.
//                A default 'red' circle image has been added.
//                """
//            )
//            return UIImage.circleImage
//        }
//    }
//    
//    // MARK: - General
//
////
////    public var pause: UIImage = loadImageSafely(with: "pause")
////    public var play: UIImage = loadImageSafely(with: "play")
////    public var target: UIImage = loadImageSafely(with: "target")
////    public var arrowRight: UIImage = loadImageSafely(with: "arrow_right")
////    
////    public var loading: UIImage = loadImageSafely(with: "loading")
//    
//
//    // MARK: - Reactions
//
////    public var reactionLoveSmall: UIImage = loadImageSafely(with: "reaction_love_small")
////    public var reactionLoveBig: UIImage = loadImageSafely(with: "reaction_love_big")
////    public var reactionLolSmall: UIImage = loadImageSafely(with: "reaction_lol_small")
////    public var reactionLolBig: UIImage = loadImageSafely(with: "reaction_lol_big")
////    public var reactionThumgsUpSmall: UIImage = loadImageSafely(with: "reaction_thumbsup_small")
////    public var reactionThumgsUpBig: UIImage = loadImageSafely(with: "reaction_thumbsup_big")
////    public var reactionThumgsDownSmall: UIImage = loadImageSafely(with: "reaction_thumbsdown_small")
////    public var reactionThumgsDownBig: UIImage = loadImageSafely(with: "reaction_thumbsdown_big")
////    public var reactionWutSmall: UIImage = loadImageSafely(with: "reaction_wut_small")
////    public var reactionWutBig: UIImage = loadImageSafely(with: "reaction_wut_big")
//
//    // MARK: - MessageList
//
////    public var messageListErrorIndicator: UIImage = loadImageSafely(with: "error_indicator")
//
//    // MARK: - FileIcons
//
////    public var file7z: UIImage = loadImageSafely(with: "7z")
////    public var fileCsv: UIImage = loadImageSafely(with: "csv")
////    public var fileDoc: UIImage = loadImageSafely(with: "doc")
////    public var fileDocx: UIImage = loadImageSafely(with: "docx")
////    public var fileHtml: UIImage = loadImageSafely(with: "html")
////    public var fileMd: UIImage = loadImageSafely(with: "md")
////    public var fileMp3: UIImage = loadImageSafely(with: "mp3")
////    public var fileOdt: UIImage = loadImageSafely(with: "odt")
////    public var filePdf: UIImage = loadImageSafely(with: "pdf")
////    public var filePpt: UIImage = loadImageSafely(with: "ppt")
////    public var filePptx: UIImage = loadImageSafely(with: "pptx")
////    public var fileRar: UIImage = loadImageSafely(with: "rar")
////    public var fileRtf: UIImage = loadImageSafely(with: "rtf")
////    public var fileTargz: UIImage = loadImageSafely(with: "tar.gz")
////    public var fileTxt: UIImage = loadImageSafely(with: "txt")
////    public var fileXls: UIImage = loadImageSafely(with: "xls")
////    public var fileXlsx: UIImage = loadImageSafely(with: "xlsx")
////    public var filezip: UIImage = loadImageSafely(with: "zip")
////    public var fileFallback: UIImage = loadImageSafely(with: "generic")
//
////    private var _documentPreviews: [String: UIImage]?
////
////    public var documentPreviews: [String: UIImage] {
////        get { _documentPreviews ??
////            [
////                "7z": file7z,
////                "csv": fileCsv,
////                "doc": fileDoc,
////                "docx": fileDocx,
////                "html": fileHtml,
////                "md": fileMd,
////                "mp3": fileMp3,
////                "odt": fileOdt,
////                "pdf": filePdf,
////                "ppt": filePpt,
////                "pptx": filePptx,
////                "rar": fileRar,
////                "rtf": fileRtf,
////                "tar.gz": fileTargz,
////                "txt": fileTxt,
////                "xls": fileXls,
////                "xlsx": fileXlsx,
////                "zip": filezip
////            ]
////        }
////        set { _documentPreviews = newValue }
////    }
////
////    // MARK: - Message Actions
////
////    public var messageActionInlineReply: UIImage = loadImageSafely(with: "icn_inline_reply")
////    public var messageActionThreadReply: UIImage = loadImageSafely(with: "icn_thread_reply")
////    public var messageActionEdit: UIImage = loadImageSafely(with: "icn_edit")
////    public var messageActionCopy: UIImage = loadImageSafely(with: "icn_copy")
////    public var messageActionBlockUser: UIImage = loadImageSafely(with: "icn_block_user")
////    public var messageActionMuteUser: UIImage = loadImageSafely(with: "icn_mute_user")
////    public var messageActionDelete: UIImage = loadImageSafely(with: "icn_delete")
////    public var messageActionResend: UIImage = loadImageSafely(with: "icn_resend")
////
////    // MARK: - Placeholders
////
////    public var userAvatarPlaceholder1: UIImage = loadImageSafely(with: "user_with_box")
////    public var userAvatarPlaceholder2: UIImage = loadImageSafely(with: "pattern2")
////    public var userAvatarPlaceholder3: UIImage = loadImageSafely(with: "pattern3")
////    public var userAvatarPlaceholder4: UIImage = loadImageSafely(with: "pattern4")
////    public var userAvatarPlaceholder5: UIImage = loadImageSafely(with: "pattern5")
////
////    public var avatarPlaceholders: [UIImage] {
////        [
////            userAvatarPlaceholder1,
////            userAvatarPlaceholder2,
////            userAvatarPlaceholder3,
////            userAvatarPlaceholder4,
////            userAvatarPlaceholder5
////        ]
////    }
////    
////    public var imagePlaceholder: UIImage = UIImage(systemName: "photo")!
////    public var personPlaceholder: UIImage = UIImage(systemName: "person.circle")!
////    
////    // MARK: - MessageSearch
////    
////    public var searchIcon: UIImage = loadImageSafely(with: "icn_search")
////    public var searchCloseIcon: UIImage = UIImage(systemName: "multiply.circle")!
//    
//}
