//
//  ImageAndViderEditor.swift
//  ISMChatSdk
//
//  Created by Rasika on 03/04/24.
//

import SwiftUI
import AVKit
import Kingfisher
import IsometrikChat


public struct ISMMediaUpload : Hashable {
    public var url : URL
    public var caption : String
    public var isVideo: Bool
}

struct ISMImageAndViderEditor: View {
    
    //MARK:  - PROPERTIES
    @State public var selectedIndex = 0
    @Binding public var media : [ISMMediaUpload]
    @Environment(\.dismiss) var dismiss
    @State public var scale: CGFloat = 1.0
    @State public var height: CGFloat = 32.0
    public var sendToUser : String
    @Binding public var sendMedia : Bool
    @State public var showCropper : Bool = false
    @State public var navigateToDraw : Bool = false
    @State public var addText : Bool = false
    
    //MARK:  - LIFECYCLE
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack {
                GeometryReader { proxy in
                    TabView(selection: $selectedIndex) {
                        ForEach(media.indices, id: \.self) { ind in
                            VStack {
                                if media[ind].isVideo {
                                    VideoPlayerView(url: media[ind].url)
                                } else {
                                    ImageView(url: media[ind].url)
                                }
                            }
                            .tag(ind)
                        }
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                Spacer().frame(height: 150)
            }
            VStack{
                Spacer()
                LazyHStack(spacing: 10) {
                    ForEach(media.indices, id: \.self) { index in
                        GeometryReader { geometry in
                            if let uiImage = ISMChatHelper.isVideo(media: media[index].url) == true ? ISMChatHelper.getThumbnailImage(url: media[index].url.absoluteString) : loadImageFromURL(fileURL: media[index].url) {
                                ZStack{
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .cornerRadius(8)
                                        .frame(width: 46, height: 46, alignment: .center)
                                        .scaledToFill()
                                        .overlay(RoundedRectangle(cornerRadius: 8)
                                            .stroke(lineWidth: 2)
                                            .foregroundColor(selectedIndex == index ? Color.white : Color.clear)
                                        )
                                        .overlay(
                                            LinearGradient(gradient: Gradient(colors: selectedIndex == index ? [Color.gray.opacity(0.6), Color.clear] : [Color.clear,Color.clear]), startPoint: .leading, endPoint: .trailing)
                                                .frame(width: 46, height: 46) // Adjust the width as needed
                                                .offset(x: 5)
                                        )
                                        .onTapGesture {
                                            if selectedIndex == index{
                                                //delete
                                                if self.media.count == 1{
                                                    self.media.removeAll()
                                                    dismiss()
                                                }else{
                                                    self.media.remove(at: index)
                                                }
                                            }else{
                                                selectedIndex = index
                                            }
                                        }
                                    if selectedIndex == index{
                                        Image("Delete_Image")
                                            .resizable()
                                            .frame(width: 21, height: 23, alignment: .center)
                                    }
                                }
                            } else {
                                Text("Image not found").foregroundColor(.white)
                            }
                        }
                        .frame(width: 50, height: 50)
                    }
                    .padding(.horizontal, 10)
                }
                .frame(height: 55)
                
                if selectedIndex <= (media.count - 1){
                    TextField("", text: $media[selectedIndex].caption,  axis: .vertical)
                        .lineLimit(1...10)
                        .font(Font.regular(size: 16))
                        .foregroundColor(Color.white)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal,15)
                        .background(Color.black)
                        .colorScheme(.dark)
                        .disableAutocorrection(true)
                        .overlay(
                            HStack{
                                Text("Add a caption....")
                                    .foregroundColor(Color.white)
                                    .padding(.horizontal,25)
                                    .opacity(media[selectedIndex].caption.isEmpty ? 1 : 0)
                                Spacer()
                            }
                        )
                }
                HStack {
                    Text(sendToUser)
                        .font(.regular(size: 14))
                        .foregroundColor(Color(hex: "#9EA4C3"))
                        .padding(.horizontal,10)
                        .padding(.vertical,5)
                        .background(Color(hex: "#9EA4C3").opacity(0.3))
                        .cornerRadius(8)
                    
                    Spacer()
                    
                    Button(action: {
                        sendMedia = true
                        dismiss()
                    }) {
                        Image("send_Media")
                            .resizable()
                            .frame(width: 36, height: 36, alignment: .center)
                    }
                }.padding(.bottom,20).padding(.horizontal,15)
            }
        }
        .sheet(isPresented: $showCropper, content: {
            ISMImageCropper(imageUrl: $media[selectedIndex].url, isShowing: $showCropper)
        })
        .fullScreenCover(isPresented: $navigateToDraw, content: {
            ISMImageDraw(url: $media[selectedIndex].url, isShowing: $navigateToDraw)
        })
        .fullScreenCover(isPresented: $addText, content: {
            ISMImageText(url: $media[selectedIndex].url, isShowing: $addText)
        })
        .onChange(of: selectedIndex){ _ in
            print("selected Index ---> \(selectedIndex)")
        }
        .onAppear(perform: {
            print("selected Index ---> \(selectedIndex)")
            print(media)
        })
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(leading: navBarLeadingBtn, trailing: navBarTrailingBtn)
    }
    
    //MARK: - CONFIGURE
    var navBarTrailingBtn: some View {
        HStack {
            if media.count > 0{
                if media[selectedIndex].isVideo == false{
                    Button(action: {
                        showCropper = true
                    }) {
                        Image("crop_Image")
                            .resizable()
                            .frame(width: 36, height: 36, alignment: .center)
                    }
                    
                    
                    Button(action: {
                        addText = true
                    }) {
                        Image("AddText")
                            .resizable()
                            .frame(width: 36, height: 36, alignment: .center)
                    }
                    
                    Button(action: {
                        navigateToDraw = true
                    }) {
                        Image("edit_Image")
                            .resizable()
                            .frame(width: 36, height: 36, alignment: .center)
                    }
                }
            }
        }
    }
    
    var navBarLeadingBtn: some View {
        Button(action: {
            media.removeAll()
            dismiss()
        }) {
            Image("close_black_background")
                .resizable()
                .frame(width: 36, height: 36, alignment: .center)
        }
    }
    
    func loadImageFromURL(fileURL: URL) -> UIImage? {
        do {
            let imageData = try Data(contentsOf: fileURL)
            return UIImage(data: imageData)
        } catch {
            print("Error loading image:", error.localizedDescription)
            return nil
        }
    }
    
    func VideoPlayerView(url : URL) -> some View{
        let vp =  AVPlayer(url:  url)
        return VideoPlayer(player: vp)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
            .onAppear{vp.pause()}
            .onDisappear{vp.pause()}
    }
    
    func ImageView(url : URL) -> some View{
        VStack{
            if let uiImage = loadImageFromURL(fileURL: url) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
            }
        }
    }
}
