//
//  ISMPDFMessageView.swift
//  ISMChatSdk
//
//  Created by Dheeraj Kumar Sharma on 26/10/23.
//

import SwiftUI
import PDFKit
import IsometrikChat

/// A SwiftUI view that displays a PDF message with a thumbnail preview and file information
/// This view is responsible for rendering PDF attachments in the chat interface
struct ISMPDFMessageView: View {
    //MARK: - PROPERTIES
    
    /// Stores the generated thumbnail image of the PDF's first page
    @State private var thumbnailImage: UIImage = UIImage()
    
    /// The URL pointing to the PDF file location
    var pdfURL: URL!
    
    /// The display name of the PDF file
    var fileName: String = ""
    
    /// UI appearance configuration instance for consistent styling
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    
    //MARK: - BODY
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                // PDF thumbnail preview
                Image(uiImage: thumbnailImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxHeight: 120)
                    .clipped()
                
                // File information row
                HStack(alignment: .top,spacing: 10, content: {
                    // PDF icon
                    appearance.images.pdfLogo
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                    
                    // File name display
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
            // Generate thumbnail when view appears
            self.pdfThumbnail(url: pdfURL!){ image in
                guard let image else { return }
                thumbnailImage = image
            }
        })
    }
    
    /// Generates a thumbnail image from the first page of a PDF file
    /// - Parameters:
    ///   - url: The URL of the PDF file
    ///   - width: The desired width of the thumbnail (default: 240)
    ///   - completion: Closure called with the generated thumbnail image
    func pdfThumbnail(url: URL, width: CGFloat = 240, _ completion: @escaping ((UIImage?) -> Void)) {
        // Perform thumbnail generation on background thread
        DispatchQueue.global(qos: .userInitiated).async {
            
            // Attempt to load PDF data and get first page
            guard let data = try? Data(contentsOf: url),
                  let page = PDFDocument(data: data)?.page(at: 0) else {
                DispatchQueue.main.async {
                    completion(UIImage())
                }
                return
            }
            
            // Calculate appropriate scaling for thumbnail
            let pageSize = page.bounds(for: .mediaBox)
            let pdfScale = width / pageSize.width
            
            // Account for device screen scale for proper resolution
            let scale = UIScreen.main.scale * pdfScale
            let screenSize = CGSize(width: pageSize.width * scale,
                                    height: pageSize.height * scale)
            
            completion(page.thumbnail(of: screenSize, for: .mediaBox))
        }
    }
}

