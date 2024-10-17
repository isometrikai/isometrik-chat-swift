//
//  ISMPDFMessageView.swift
//  ISMChatSdk
//
//  Created by Dheeraj Kumar Sharma on 26/10/23.
//

import SwiftUI
import PDFKit
import IsometrikChat

struct ISMPDFMessageView: View {
    //MARK:  - PROPERTIES
    
    @State private var thumbnailImage: UIImage = UIImage()
    var pdfURL: URL!
    var fileName: String = ""
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    
    //MARK:  - BODY
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                Image(uiImage: thumbnailImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxHeight: 120)
                    .clipped()
                HStack(alignment: .top,spacing: 10, content: {
                    appearance.images.pdfLogo
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                    Text("\(fileName)")
                        .font(appearance.fonts.messageListMessageText)
                        .foregroundColor(appearance.colorPalette.messageListHeaderTitle)
                        .lineLimit(2)
                })
                .padding(EdgeInsets(top: 3, leading: 10, bottom: 8, trailing: 10))
            }
            .background(appearance.colorPalette.messageListattachmentBackground)
            .cornerRadius(5)
        }
        .onAppear( perform: {
            self.pdfThumbnail(url: pdfURL!){ image in
                guard let image else { return }
                thumbnailImage = image
            }
        })
    }
    
    func pdfThumbnail(url: URL, width: CGFloat = 240, _ completion: @escaping ((UIImage?) -> Void)) {
        DispatchQueue.global(qos: .userInitiated).async {
            
            guard let data = try? Data(contentsOf: url),
                  let page = PDFDocument(data: data)?.page(at: 0) else {
                DispatchQueue.main.async {
                    completion(UIImage())
                }
                return
            }
            
            let pageSize = page.bounds(for: .mediaBox)
            let pdfScale = width / pageSize.width
            
            // Apply if you're displaying the thumbnail on screen
            let scale = UIScreen.main.scale * pdfScale
            let screenSize = CGSize(width: pageSize.width * scale,
                                    height: pageSize.height * scale)

            completion(page.thumbnail(of: screenSize, for: .mediaBox))
            
        }
    }
}

//struct ISMPDFMessageView_Previews: PreviewProvider {
//    static var previews: some View {
//        ISMPDFMessageView()
//    }
//}
