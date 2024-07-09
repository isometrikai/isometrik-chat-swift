//
//  ISMImageText.swift
//  ISMChatSdk
//
//  Created by Rasika on 09/04/24.
//

import SwiftUI
import IsometrikChat

struct TextBox : Identifiable{
    var id = UUID().uuidString
    var text : String = ""
    var isBold : Bool = false
    var offset: CGSize = .zero
    var lastoffset: CGSize = .zero
    var textColor : Color = .black
    var isAdded : Bool = false
}

struct ISMImageText: View {
    @Binding var url : URL
    @Binding var isShowing : Bool
    @State var textBoxes : [TextBox] = []
    @State var addNewBox = false
    @State var currentIndex : Int = 0
    @State var imageData : Data = Data(count: 0)
    @State var rect : CGRect = .zero
    
    var body: some View {
        NavigationView{
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
    
    func getIndex(textBox : TextBox)-> Int{
        let index = textBoxes.firstIndex{ (box) -> Bool in
            return textBox.id == box.id
            
        } ?? 0
        return index
    }
    
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
    
    func AddNewTextField(){
        textBoxes.append(TextBox())
        currentIndex = textBoxes.count - 1
        withAnimation {
            addNewBox = true
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
    
    func cancelImageText(){
        withAnimation {
            addNewBox = false
        }
        if !textBoxes[currentIndex].isAdded{
            textBoxes.removeLast()
        }
    }
    
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
        
        let newUrl = ISMChat_Helper.createImageURL()
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
}

struct CanvasViewNew :  UIViewRepresentable {
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
