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
    //MARK:  - PROPERTIES
    @Binding var url : URL
    @State var canvas = PKCanvasView()
    @State var imageData : Data = Data(count: 0)
    @State var toolpicker = PKToolPicker()
    @Binding var isShowing : Bool
    @State var rect : CGRect = .zero
    
    //MARK:  - LIFECYCLE
    var body: some View {
        NavigationView{
            ZStack{
                GeometryReader{proxy -> AnyView in
                    let size = proxy.frame(in: .global).size
                    DispatchQueue.main.async {
                        rect = proxy.frame(in: .global)
                    }
                    return AnyView(
                        CanvasView(canvas: $canvas, imageData: $imageData, toolPicker:  $toolpicker, rect: size)
                    )
                }
            }.onAppear(perform: {
                fetchData(from: url)
            })
            .navigationBarBackButtonHidden()
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: navBarLeadingBtn, trailing: navBarTrailingBtn)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
    
    //MARK: - CONFIGURE
    
    var navBarTrailingBtn: some View {
        Button(action: {
            save()
        }) {
            Text("Done")
                .foregroundColor(.blue)
        }
    }
    
    var navBarLeadingBtn: some View {
        Button(action: {
            cancelImageEditing()
        }) {
            Text("Cancel")
                .foregroundColor(.blue)
        }
    }
    
    func fetchData(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                DispatchQueue.main.async {
                    self.imageData = data
                }
            }
        }.resume()
    }
    
    func cancelImageEditing(){
        canvas = PKCanvasView()
        isShowing = false
    }
    
    func save(){
        UIGraphicsBeginImageContextWithOptions(self.rect.size, false, 1)
        canvas.drawHierarchy(in: CGRect(origin: .zero, size: self.rect.size), afterScreenUpdates: true)
        let generatedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if let image = generatedImage{
            let newUrl = ISMChat_Helper.createImageURL()
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


struct CanvasView :  UIViewRepresentable{
    @Binding var canvas : PKCanvasView
    @Binding var imageData : Data
    @Binding var toolPicker : PKToolPicker
    var rect : CGSize
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvas.isOpaque = false
        canvas.backgroundColor = .clear
        canvas.drawingPolicy = .anyInput
        return canvas
    }
    
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
