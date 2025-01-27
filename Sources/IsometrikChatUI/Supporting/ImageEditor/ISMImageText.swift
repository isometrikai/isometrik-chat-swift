//
//  ISMImageText.swift
//  ISMChatSdk
//
//  Created by Rasika on 09/04/24.
//

import SwiftUI
import IsometrikChat

/// Represents a text box that can be added and manipulated on an image
struct TextBox : Identifiable {
    var id = UUID().uuidString
    var text : String = ""
    var isBold : Bool = false
    /// Current position of the text box
    var offset: CGSize = .zero
    /// Previous position of the text box (used for drag calculations)
    var lastoffset: CGSize = .zero
    var textColor : Color = .black
    /// Flag to track if text box has been confirmed/added
    var isAdded : Bool = false
}

/// View for adding and editing text overlays on images
struct ISMImageText: View {
    
    // MARK: - Properties
    @Binding var url : URL
    @Binding var isShowing : Bool
    /// Array of text boxes added to the image
    @State var textBoxes : [TextBox] = []
    /// Flag to show text input interface
    @State var addNewBox = false
    /// Index of currently selected text box
    @State var currentIndex : Int = 0
    /// Raw image data
    @State var imageData : Data = Data(count: 0)
    @State var rect : CGRect = .zero
    
    var body: some View {
        NavigationStack{
            ZStack{
                GeometryReader{ geometry in
                    ZStack{
                        Image(uiImage: UIImage(data: imageData) ?? UIImage())
                            .resizable()
                            .aspectRatio(contentMode: .fit) // Ensure image fits without zooming
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .clipped()
                        
                        ForEach(textBoxes) { box in
                            Text(textBoxes[currentIndex].id == box.id && addNewBox ? "" : box.text)
                                .font(.system(size: 30))
                                .fontWeight(box.isBold ? .bold : .none)
                                .foregroundColor(box.textColor)
                                .offset(box.offset)
                                .gesture(DragGesture().onChanged({ (value) in
                                    let current = value.translation
                                    let lastOffset = box.lastoffset
                                    let newTranslation = CGSize(width: lastOffset.width + current.width, height: lastOffset.height + current.height)
                                    textBoxes[getIndex(textBox: box)].offset = newTranslation
                                }).onEnded({ (value) in
                                    textBoxes[getIndex(textBox: box)].lastoffset = value.translation
                                })).onLongPressGesture {
                                    currentIndex = getIndex(textBox: box)
                                    withAnimation {
                                        addNewBox = true
                                    }
                                }
                        }
                    }
                    
                }
                
                if addNewBox{
                    Color.black.opacity(0.75)
                        .ignoresSafeArea()
                    VStack{
                        HStack{
                            
                        }.overlay {
                            ColorPicker("",selection: $textBoxes[currentIndex].textColor)
                                .labelsHidden()
                        }
                        Spacer()
                        TextField("Type Here", text: $textBoxes[currentIndex].text)
                            .font(.system(size: 35))
                            .colorScheme(.dark)
                            .foregroundColor(textBoxes[currentIndex].textColor)
                            .padding()
                        Spacer()
                    }
                }
                
            }.onAppear(perform: {
                fetchData(from: url)
            })
            .navigationBarBackButtonHidden()
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: navBarLeadingBtn, trailing: navBarTrailingBtn)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
    
    /// Returns the index of a given text box in the textBoxes array
    /// - Parameter textBox: The text box to find
    /// - Returns: Index of the text box, or 0 if not found
    func getIndex(textBox : TextBox)-> Int {
        let index = textBoxes.firstIndex{ (box) -> Bool in
            return textBox.id == box.id
            
        } ?? 0
        return index
    }
    
    /// Adds a new text box and shows the text input interface
    func AddNewTextField() {
        textBoxes.append(TextBox())
        currentIndex = textBoxes.count - 1
        withAnimation {
            addNewBox = true
        }
    }
    
    /// Fetches image data from the provided URL
    /// - Parameter url: URL of the image to load
    func fetchData(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                DispatchQueue.main.async {
                    self.imageData = data
                }
            }
        }.resume()
    }
    
    /// Handles cancellation of text input
    /// Removes the text box if it wasn't confirmed
    func cancelImageText(){
        withAnimation {
            addNewBox = false
        }
        if !textBoxes[currentIndex].isAdded{
            textBoxes.removeLast()
        }
    }
    
    /// Saves the image with text overlays
    /// Creates a new image by rendering the SwiftUI view hierarchy
    func save() {
        let swiftUIView =
        ZStack {
            Image(uiImage: UIImage(data: imageData) ?? UIImage())
                .resizable()
                .scaledToFit()
                .frame(width: UIScreen.main.bounds.width, height: 500, alignment: .center)
            
            ForEach(textBoxes) { box in
                Text(textBoxes[currentIndex].id == box.id && addNewBox ? "" : box.text)
                    .font(.system(size: 30))
                    .fontWeight(box.isBold ? .bold : .none)
                    .foregroundColor(box.textColor)
                    .offset(box.offset)
                    .gesture(DragGesture().onChanged({ (value) in
                        let current = value.translation
                        let lastOffset = box.lastoffset
                        let newTranslation = CGSize(width: lastOffset.width + current.width, height: lastOffset.height + current.height)
                        textBoxes[getIndex(textBox: box)].offset = newTranslation
                    }).onEnded({ (value) in
                        textBoxes[getIndex(textBox: box)].lastoffset = value.translation
                    })).onLongPressGesture {
                        currentIndex = getIndex(textBox: box)
                        withAnimation {
                            addNewBox = true
                        }
                    }
            }
        }
        .drawingGroup()
        
        var uiimage = UIImage()
        let controller = UIHostingController(rootView: swiftUIView)
        
        if let view = controller.view{
            let contentSize = view.intrinsicContentSize
            view.bounds = CGRect(origin: .zero, size: contentSize)
            view.backgroundColor = .clear
            
            let renderer = UIGraphicsImageRenderer(size: contentSize)
            uiimage = renderer.image{ _ in
                view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
            }
        }
        
        let newUrl = ISMChatHelper.createImageURL()
        if let imageData = uiimage.pngData() {
            do {
                try imageData.write(to: newUrl)
                url = newUrl
                isShowing = false
            } catch {
                print("Error writing cropped image: \(error)")
                isShowing = false
            }
        }
    }
    
    // MARK: - Navigation Bar Items
    
    var navBarTrailingBtn: some View {
        HStack{
            if addNewBox == false{
                
                Button(action: {
                    AddNewTextField()
                }) {
                    Image(systemName: "plus")
                }
                Button(action: {
                    save()
                }) {
                    Text("Done")
                        .foregroundColor(.blue)
                }
            }else{
                Button(action: {
                    textBoxes[currentIndex].isAdded = true
                    withAnimation {
                        addNewBox = false
                    }
                }) {
                    Text("Done")
                        .foregroundColor(.blue)
                }
            }
        }
    }
    
    var navBarLeadingBtn: some View {
        Button(action: {
            addNewBox == false ? withAnimation {
                isShowing = false
            } : cancelImageText()
        }) {
            Text("Cancel")
                .foregroundColor(.blue)
        }
    }
}

/// UIView wrapper for displaying the image
struct CanvasViewNew : UIViewRepresentable {
    @Binding var imageData : Data
    var rect : CGSize
    
    func makeUIView(context: Context) -> UIView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let image = UIImage(data: imageData){
            let imageView = UIImageView(image: image)
            imageView.frame = CGRect(x: 0, y: 0, width: rect.width, height: rect.height)
            imageView.contentMode = .scaleAspectFit
            imageView.clipsToBounds = true
        }
    }
}
