//
//  ISMDocumentViewer.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 08/05/23.
//

import UIKit
import SwiftUI
import PDFKit
import IsometrikChat


struct ISMDocumentViewer: View {
    
    //MARK:  - PROPERTIES
    let url: URL?
    let title : String
    @State var currentPage: Int = 0
    @State var total: Int = 0
    @State private var isShowingActivityView = false
    @State private var documentSaved : Bool = false
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    @Environment(\.dismiss) var dismiss
    
    //MARK:  - LIFECYCLE
    var body: some View {
        ZStack{
            if let url = url{
                VStack {
                    // Using the PDFKitView and passing the previously created pdfURL
                    if url.absoluteString.contains(".pdf"){
                        PDFKitView(url: url).scaledToFill()
                    }else{
                        TextFileView(url: url)
                    }
                        
                }.navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            VStack {
                                Text(title)
                                    .font(appearance.fonts.mediaSliderHeader)
                                    .foregroundColor(appearance.colorPalette.mediaSliderHeader)
                            }
                        }
                    }
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Menu {
                                Button {
                                    isShowingActivityView = true
                                } label: {
                                    Label("Share", systemImage: "square.and.arrow.up")
                                }
                                Button {
                                    saveToFile()
                                } label: {
                                    Label("Save to File", systemImage: "folder")
                                }
                            } label: {
                                appearance.images.threeDots
                                    .resizable()
                                    .frame(width: 5, height: 20, alignment: .center)
                                
                            }
                        }
                    }//:ToolBar
                    .sheet(isPresented: $isShowingActivityView) {
                        ActivityView(activityItems: [url])
                    }
            }
            if documentSaved == true{
                Text("Saved to File.")
                    .font(Font.caption)
                    .padding()
                    .background(.black.opacity(0.4))
                    .foregroundColor(.white)
                    .cornerRadius(5)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            documentSaved = false
                        }
                    }
            }
        } .navigationBarBackButtonHidden()
            .navigationBarItems(leading: navigationBarLeadingButtons())
    }
    
    
    
    func navigationBarLeadingButtons()  -> some View {
        Button(action: {
            dismiss()
        }) {
            appearance.images.CloseSheet
                .resizable()
                .frame(width: appearance.imagesSize.backButton.width, height: appearance.imagesSize.backButton.height)
        }
    }
    
    func saveToFile(){
        if let url = url{
            FileDownloader.loadFileAsync(url: url) { (path, error) in
                if let path = path{
                    print("PDF File downloaded to : \(path)")
                    documentSaved = true
                }
            }
        }
    }
    
    func actionSheet() {
        if let url = url {
            let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)

            // Get the active window from the foreground scene
            if let keyWindow = UIApplication.shared.connectedScenes
                .filter({ $0.activationState == .foregroundActive })
                .compactMap({ $0 as? UIWindowScene })
                .flatMap({ $0.windows })
                .first(where: { $0.isKeyWindow }) {

                keyWindow.rootViewController?.present(activityVC, animated: true, completion: nil)
            }
        }
    }
}

struct PDFKitRepresentedView: UIViewRepresentable {
    
    //MARK:  - PROPERTIES
    let url: URL
    @Binding var currentPage: Int
    @Binding var total: Int
    init(_ url: URL, _ currentPage: Binding<Int>, _ total: Binding<Int>) {
        self.url = url
        self._currentPage = currentPage
        self._total = total
    }
    
    //MARK:  - LIFECYCLE
    func makeUIView(context: Context) -> UIView {
        guard let document = PDFDocument(url: self.url) else { return UIView() }
        
        let pdfView = PDFView()
        ISMChatHelper.print("PDFVIEW IS CREATED")
        pdfView.document = document
        pdfView.displayMode = .singlePage
        pdfView.displayDirection = .horizontal
        pdfView.autoScales = true
        pdfView.usePageViewController(true)
        
        DispatchQueue.main.async {
            self.total = document.pageCount
            ISMChatHelper.print("Total pages: \(total)")
        }
        return pdfView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        guard let pdfView = uiView as? PDFView else { return }
        
        if currentPage < total {
            pdfView.go(to: pdfView.document!.page(at: currentPage)!)
        }
    }
}

struct PDFKitView: UIViewRepresentable {
    let url: URL // new variable to get the URL of the document
    
    func makeUIView(context: UIViewRepresentableContext<PDFKitView>) -> PDFView {
        // Creating a new PDFVIew and adding a document to it
        let pdfView = PDFView()
        pdfView.document = PDFDocument(url: self.url)
        pdfView.autoScales = true
        pdfView.minScaleFactor = 0.6
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: UIViewRepresentableContext<PDFKitView>) {
        // we will leave this empty as we don't need to update the PDF
    }
}

struct TextFileView: View {
    let url: URL // The URL to the .txt file
    @State private var fileContent: String = "" // To hold the file content
    @State private var isLoading: Bool = true

    var body: some View {
        ZStack {
            if isLoading {
                // Show a loading indicator while the file is being fetched
                ProgressView("Loading...")
                    .progressViewStyle(CircularProgressViewStyle())
            } else if !fileContent.isEmpty {
                // Display the content of the .txt file
               
                    GeometryReader { geometry in
                        ScrollView {
                            Text(fileContent)
                                .padding()
                                .font(.system(.body, design: .monospaced)) // Monospaced font for code
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .frame(minHeight: geometry.size.height) // Ensure content adapts to available space
                        }
                        .frame(width: geometry.size.width, height: geometry.size.height) // Apply frame to ScrollView
                    }
                
            } else {
                Text("Unable to load content.")
            }
        }
        .onAppear {
            loadTextFile()
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    // Function to load the content of the .txt file
    func loadTextFile() {
            let request = URLRequest(url: url)
            
            // Perform the request asynchronously
            URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    // Hide the loading indicator
                    isLoading = false

                    // Handle any errors
                    if let error = error {
                        print("Error loading file: \(error.localizedDescription)")
                        fileContent = "Error loading file."
                        return
                    }

                    // Check if data is available
                    if let data = data, let content = String(data: data, encoding: .utf8) {
                        fileContent = content
                    } else {
                        fileContent = "Unable to load content."
                    }
                }
            }.resume() // Start the request
        }
}

struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
