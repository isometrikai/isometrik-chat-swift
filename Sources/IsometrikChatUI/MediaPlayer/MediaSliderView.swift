//
//  MediaSliderView.swift
//  ISMChatSdk
//
//  Created by Rasika on 04/07/23.
//

import SwiftUI
import IsometrikChat
import AVKit
import SDWebImageSwiftUI
import PhotosUI

struct MediaSliderView: View {
    
    // MARK: - PROPERTIES
    
    var viewModel = ChatsViewModel()
    var messageId = "0"
    @State private var selectedIndex: Int = 0
    @EnvironmentObject var reamlManager: RealmManager
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    @Environment(\.dismiss) var dismiss
    @State var onScreen : Bool = false
    
    // MARK: - BODY
    var body: some View {
        VStack {
            if let data = reamlManager.medias {
                VStack {
                    GeometryReader { proxy in
                        TabView(selection: $selectedIndex) {
                            ForEach(0..<data.count, id: \.self) { i in
                                let userName = data[i].userName
                                MediaContentView(data: data[i], proxy: proxy) // Move content to a separate view for better performance
                                    .frame(width: proxy.size.width, height: proxy.size.height)
                                    .tag(i)
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        .frame(maxHeight: .infinity, alignment: .center)
                        .animation(.easeInOut, value: selectedIndex) // Smooth animation
                    }
                    
//                    ScrollView(.horizontal, showsIndicators: false) {
//                    ScrollViewReader { scrollViewProxy in
//                         // Make sure it's a horizontal scroll view
//                            HStack(spacing: 1) { // Adjust spacing as needed
//                                ForEach(data.indices, id: \.self) { index in
//                                    let uiImage = ISMChatHelper.isVideoString(media: data[index].mediaUrl) ? data[index].thumbnailUrl : data[index].mediaUrl
//                                    ISMChatImageCahcingManger.networkImage(url: uiImage, isprofileImage: false)
//                                        .resizable()
//                                        .scaledToFill()
//                                        .frame(width: index == selectedIndex ? 35 : 30, height: 35) // Adjust the thumbnail size as needed
//                                        .clipped()
//                                        .padding(.horizontal,index == selectedIndex ? 10 : 0)
//                                        .id(index) // Assign an ID to scroll to this specific item
//                                        .onTapGesture {
//                                            selectedIndex = index
//                                            withAnimation {
//                                                scrollToCenter(proxy: scrollViewProxy, index: index, count: data.count)
//                                            }
//                                        }
//                                }
//                            }.onAppear {
//                                scrollToCenter(proxy: scrollViewProxy, index: selectedIndex, count: data.count)
//                            }
//                            .onChange(of: selectedIndex) { index in
//                                withAnimation {
//                                    scrollToCenter(proxy: scrollViewProxy, index: index, count: data.count)
//                                }
//                            }
//                        }
//                        
//                    }
//                    .frame(height: 35,alignment: .center) // Set height according to thumbnail size
//                    .padding(.bottom, 10)

                    

                    
                    // Optional buttons
//                    HStack {
//                        Button { 
//                            
//                        } label: {
//                            Image(systemName: "square.and.arrow.up")
//                                .resizable() // Makes the image resizable
//                                .aspectRatio(contentMode: .fit) // Maintains the aspect ratio of the image
//                                .frame(width: 20, height: 20) // Set the desired width and height
//                                .foregroundColor(.black)
//                        }
//                        Spacer()
//                        Button { 
//                            
//                        } label: {
//                            Image(systemName: "arrowshape.turn.up.right")
//                                .resizable() // Makes the image resizable
//                                .aspectRatio(contentMode: .fit) // Maintains the aspect ratio of the image
//                                .frame(width: 20, height: 20) // Set the desired width and height
//                                .foregroundColor(.black)
//                        }
//                        Spacer()
//                        Button { 
//                            downloadImage(from: data[selectedIndex].mediaUrl)
//                        } label: {
//                            Image(systemName: "square.and.arrow.down")
//                                .resizable() // Makes the image resizable
//                                .aspectRatio(contentMode: .fit) // Maintains the aspect ratio of the image
//                                .frame(width: 20, height: 20) // Set the desired width and height
//                                .foregroundColor(.black)
//                        }
//                        Spacer()
//                        Button { 
//                            
//                        } label: {
//                            Image(systemName: "trash")
//                                .resizable() // Makes the image resizable
//                                .aspectRatio(contentMode: .fit) // Maintains the aspect ratio of the image
//                                .frame(width: 20, height: 20) // Set the desired width and height
//                                .foregroundColor(.black)
//                        }
//                    }
//                    .padding(.horizontal, 20)
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden()
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        VStack {
                            if onScreen == true{
                                let date = NSDate().doubletoDate(time: data[selectedIndex].sentAt)
                                let time = NSDate().doubletoTime(time: data[selectedIndex].sentAt)
                                let name = data[selectedIndex].userName == ISMChatSdk.getInstance().getChatClient().getConfigurations().userConfig.userName ? ConstantStrings.you : data[selectedIndex].userName
                                Text(name)
                                    .font(appearance.fonts.mediaSliderHeader)
                                    .foregroundColor(appearance.colorPalette.mediaSliderHeader)
                                Text("\(date), \(time)")
                                    .font(appearance.fonts.mediaSliderDescription)
                                    .foregroundColor(appearance.colorPalette.mediaSliderDescription)
                            }
                        }
                    }
                }
                .navigationBarItems(leading: navigationBarLeadingButtons())
                .onAppear {
                    onScreen = true
                    selectedIndex = messageId == "0" ? selectedIndex : (reamlManager.medias?.firstIndex(where: { $0.messageId == messageId }) ?? 0)
                }
                .onDisappear {
                    onScreen = false
                }
            }
        }
    }
    
    // Function to scroll to the selected index and keep it centered
    func scrollToCenter(proxy: ScrollViewProxy, index: Int,count : Int) {
        // Calculate the ideal offset to center the selected item
           let itemWidth: CGFloat = 31 // 30 for image width + 1 for spacing
        let centerOffset = UIScreen.main.bounds.width / 2 - itemWidth / 2
           let targetPosition = CGFloat(index) * itemWidth

           // Scroll to index with calculated offset to center
           proxy.scrollTo(index, anchor: .center)

           // Use the exact scrollTo offset for smoother centering if needed
           let xOffset = targetPosition - centerOffset
           proxy.scrollTo(index, anchor: UnitPoint(x: min(max(xOffset, 0), CGFloat(count) * itemWidth - UIScreen.main.bounds.width) / (CGFloat(count) * itemWidth), y: 0.5))
    }
    
    func navigationBarLeadingButtons() -> some View {
        Button(action: {}) {
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    appearance.images.backButton
                        .resizable()
                        .frame(width: 18, height: 18)
                }
            }
        }
    }
    func downloadImage(from url: String) {
        guard let imageURL = URL(string: url) else { return }
        
        // Fetch the image data from URL
        URLSession.shared.dataTask(with: imageURL) { data, response, error in
            if let error = error {
                print("Error downloading image: \(error)")
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                print("Invalid image data")
                return
            }
            
            // Save the image to the photo library
            saveImageToGallery(image: image)
        }.resume()
    }

    // Function to save the image to the gallery
    private func saveImageToGallery(image: UIImage) {
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                print("Image saved successfully")
            } else {
                print("Permission to save photos denied")
            }
        }
    }
}

struct MediaContentView: View {
    let data: MediaDB // Replace with actual data model
    let proxy: GeometryProxy
    
    var body: some View {
        let url = data.mediaUrl
        
        VStack {
            if data.customType == ISMChatMediaType.Video.value {
                let vp = AVPlayer(url: URL(string: url)!)
                VideoPlayer(player: vp)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                    .onAppear { vp.play() }
                    .onDisappear { vp.pause() }
            } else if data.customType == ISMChatMediaType.gif.value {
                AnimatedImage(url: URL(string: url))
                    .resizable()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ISMChatImageCahcingManger.networkImage(url: url, isprofileImage: false)
                    .resizable()
                    .scaledToFit()
                    .modifier(ImageModifier(contentSize: CGSize(width: proxy.size.width, height: proxy.size.height)))
            }
            Spacer()
            if !data.caption.isEmpty {
                VStack(alignment: .leading) {
                    Divider()
                    Text("\(data.caption)")
                        .multilineTextAlignment(.leading)
                        .foregroundColor(Color.black)
                        .font(Font.regular(size: 16))
                        .padding(.horizontal, 15)
                }
            }
        }
    }
}
