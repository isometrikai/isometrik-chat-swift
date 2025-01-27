//
//  ISMImageDraw.swift
//  ISMChatSdk
//
//  Created by Rasika on 08/04/24.
//

import SwiftUI
import UIKit
import PencilKit
import IsometrikChat


struct ISMImageDraw: View {
    //MARK: - PROPERTIES
    /// URL of the image to be edited
    @Binding var url: URL?
    /// Canvas view for drawing
    @State var canvas = PKCanvasView()
    /// Raw data of the loaded image
    @State var imageData: Data = Data(count: 0)
    /// Tool picker for drawing controls
    @State var toolpicker = PKToolPicker()
    /// Controls visibility of the drawing view
    @Binding var isShowing: Bool
    /// Stores the frame dimensions of the view
    @State var rect: CGRect = .zero
    
    //MARK: - LIFECYCLE
    var body: some View {
        NavigationStack {
            ZStack {
                GeometryReader { proxy -> AnyView in
                    // Capture the size of the view for proper scaling
                    let size = proxy.frame(in: .global).size
                    DispatchQueue.main.async {
                        rect = proxy.frame(in: .global)
                    }
                    return AnyView(
                        CanvasView(canvas: $canvas, imageData: $imageData, toolPicker: $toolpicker, rect: size)
                    )
                }
            }.onAppear {
                // Load image data when view appears
                if let url = url {
                    fetchData(from: url)
                }
            }
            .navigationBarBackButtonHidden()
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: navBarLeadingBtn, trailing: navBarTrailingBtn)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
    
    //MARK: - CONFIGURE
    /// Button to save the edited image
    var navBarTrailingBtn: some View {
        Button(action: {
            save()
        }) {
            Text("Done")
                .foregroundColor(.blue)
        }
    }
    
    /// Button to cancel image editing
    var navBarLeadingBtn: some View {
        Button(action: {
            cancelImageEditing()
        }) {
            Text("Cancel")
                .foregroundColor(.blue)
        }
    }
    
    /// Fetches image data from the provided URL
    /// - Parameter url: URL of the image to fetch
    func fetchData(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                DispatchQueue.main.async {
                    self.imageData = data
                }
            }
        }.resume()
    }
    
    /// Resets canvas and dismisses the editor
    func cancelImageEditing(){
        canvas = PKCanvasView()
        isShowing = false
    }
    
    /// Saves the edited image
    /// 1. Creates an image context with the current view size
    /// 2. Draws the canvas hierarchy into the context
    /// 3. Generates a new image from the context
    /// 4. Saves the image to a new URL
    func save(){
        UIGraphicsBeginImageContextWithOptions(self.rect.size, false, 1)
        canvas.drawHierarchy(in: CGRect(origin: .zero, size: self.rect.size), afterScreenUpdates: true)
        let generatedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if let image = generatedImage{
            let newUrl = ISMChatHelper.createImageURL()
            if let imageData = image.jpegData(compressionQuality: 1.0) {
                do {
                    try imageData.write(to: newUrl)
                    url = newUrl
                    isShowing = false
                } catch {
                    print("Error writing cropped image: \(error)")
                    isShowing = false
                }
            }
            canvas = PKCanvasView()
        }
    }
}

/// UIViewRepresentable wrapper for PKCanvasView to enable drawing functionality
struct CanvasView: UIViewRepresentable {
    @Binding var canvas: PKCanvasView
    @Binding var imageData: Data
    @Binding var toolPicker: PKToolPicker
    var rect: CGSize
    
    /// Creates and configures the initial canvas view
    func makeUIView(context: Context) -> PKCanvasView {
        canvas.isOpaque = false
        canvas.backgroundColor = .clear
        canvas.drawingPolicy = .anyInput
        return canvas
    }
    
    /// Updates the canvas view with the image and drawing tools
    /// - Sets up the image view with proper scaling
    /// - Configures the tool picker
    /// - Makes canvas the first responder
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        if let image = UIImage(data: imageData){
            let imageView = UIImageView(image: image)
            imageView.frame = CGRect(x: 0, y: 0, width: rect.width, height: rect.height)
            imageView.contentMode = .scaleAspectFit
            imageView.clipsToBounds = true
            
            let subview = canvas.subviews[0]
            subview.addSubview(imageView)
            subview.sendSubviewToBack(imageView)
            
            toolPicker.setVisible(true, forFirstResponder: canvas)
            toolPicker.addObserver(canvas)
            canvas.becomeFirstResponder()
        }
    }
}
