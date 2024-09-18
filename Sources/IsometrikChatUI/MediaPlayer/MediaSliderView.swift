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
    @State var navigatetoMedia : Bool = false
    @State var isShareSheetPresented : Bool = false
    @State var isPlaying : Bool = false
    
    
    // MARK: - BODY
    var body: some View {
        VStack {
            if let data = reamlManager.medias {
                VStack {
                    GeometryReader { proxy in
                        TabView(selection: $selectedIndex) {
                            ForEach(0..<data.count, id: \.self) { i in
                                MediaContentView(data: data[i], proxy: proxy, isPlaying: $isPlaying) // Move content to a separate view for better performance
                                    .frame(width: proxy.size.width, height: proxy.size.height)
                                    .tag(i)
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        .frame(maxHeight: .infinity, alignment: .center)
                        .animation(.easeInOut, value: selectedIndex) // Smooth animation
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                    ScrollViewReader { scrollViewProxy in
                         // Make sure it's a horizontal scroll view
                            HStack(spacing: 1) { // Adjust spacing as needed
                                ForEach(data.indices, id: \.self) { index in
                                    let uiImage = ISMChatHelper.isVideoString(media: data[index].mediaUrl) ? data[index].thumbnailUrl : data[index].mediaUrl
                                    ISMChatImageCahcingManger.networkImage(url: uiImage, isprofileImage: false)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: index == selectedIndex ? 35 : 30, height: 35) // Adjust the thumbnail size as needed
                                        .clipped()
                                        .padding(.horizontal,index == selectedIndex ? 10 : 0)
                                        .id(index) // Assign an ID to scroll to this specific item
                                        .onTapGesture {
                                            selectedIndex = index
                                            withAnimation {
                                                scrollToCenter(proxy: scrollViewProxy, index: index, count: data.count)
                                            }
                                        }
                                }
                            }.onAppear {
                                scrollToCenter(proxy: scrollViewProxy, index: selectedIndex, count: data.count)
                            }
                            .onChange(of: selectedIndex, { index, _ in
                                withAnimation {
                                    scrollToCenter(proxy: scrollViewProxy, index: index, count: data.count)
                                }
                            })
                        }
                        
                    }
                    .frame(height: 35,alignment: .center) // Set height according to thumbnail size
                    .padding(.bottom, 10)

                    

                    
                    // Optional buttons
                    HStack {
                        Button { 
                            isShareSheetPresented.toggle()
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                                .resizable() // Makes the image resizable
                                .aspectRatio(contentMode: .fit) // Maintains the aspect ratio of the image
                                .frame(width: 25, height: 25) // Set the desired width and height
                                .foregroundColor(.black)
                        }
//                        Spacer()
//                        Button { 
//                            
//                        } label: {
//                            Image(systemName: "arrowshape.turn.up.right")
//                                .resizable() // Makes the image resizable
//                                .aspectRatio(contentMode: .fit) // Maintains the aspect ratio of the image
//                                .frame(width: 25, height: 25) // Set the desired width and height
//                                .foregroundColor(.black)
//                        }
                        if onScreen == true{
                            if  selectedIndex >= 0 && selectedIndex < data.count {
                                if ISMChatHelper.isVideoString(media: data[selectedIndex].mediaUrl){
                                    Spacer()
                                    Button {
                                        isPlaying.toggle()
                                    } label: {
                                        Image(systemName: isPlaying ? "pause.fill"  : "play.fill")
                                            .resizable() // Makes the image resizable
                                            .aspectRatio(contentMode: .fit) // Maintains the aspect ratio of the image
                                            .frame(width: 20, height: 20) // Set the desired width and height
                                            .foregroundColor(.black)
                                    }
                                }
                            }
                        }
                        Spacer()
                        Button { 
                            downloadImage(from: data[selectedIndex].mediaUrl)
                        } label: {
                            Image(systemName: "square.and.arrow.down")
                                .resizable() // Makes the image resizable
                                .aspectRatio(contentMode: .fit) // Maintains the aspect ratio of the image
                                .frame(width: 25, height: 25) // Set the desired width and height
                                .foregroundColor(.black)
                        }
//                        Spacer()
//                        Button { 
//                            // Perform the delete operation
//                            reamlManager.deleteMediaMessage(convID: data[selectedIndex].conversationId, messageId: data[selectedIndex].messageId)
//                            
//                            // Update the UI or data after deletion
//                            NotificationCenter.default.post(name: NSNotification.refrestMessagesListLocally, object: nil)
//                            
//                            // Adjust the selectedIndex safely
//                            if selectedIndex >= data.count {
//                                selectedIndex = max(data.count - 1, 0)
//                            }
//                            
//                            // Check if data array is empty
//                            if data.isEmpty {
//                                dismiss() // Or handle empty state, e.g., show a placeholder
//                            }
//                        } label: {
//                            Image(systemName: "trash")
//                                .resizable() // Makes the image resizable
//                                .aspectRatio(contentMode: .fit) // Maintains the aspect ratio of the image
//                                .frame(width: 20, height: 20) // Set the desired width and height
//                                .foregroundColor(.black)
//                        }
                    }
                    .padding(.horizontal, 25)
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden()
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        VStack {
                            if onScreen == true &&  selectedIndex >= 0 && selectedIndex < data.count {
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
                .background(NavigationLink("", destination:  ISMUserMediaView(viewModel:viewModel)
                    .environmentObject(self.reamlManager), isActive: $navigatetoMedia))
                .navigationBarItems(leading: navigationBarLeadingButtons(),trailing: navigationBarTrailingButtons())
                .sheet(isPresented: $isShareSheetPresented) {
                    // Present the Share Sheet
                    if onScreen == true{
                        ShareSheet(items: [data[selectedIndex].mediaUrl])
                            .presentationDetents([.fraction(0.5)])
                    }
                }
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
    
    func navigationBarTrailingButtons() -> some View {
        Button(action: {}) {
            HStack {
                Button(action: {
                    navigatetoMedia.toggle()
                }) {
                    Text("All media")
                        .font(appearance.fonts.mediaSliderHeader)
                        .foregroundColor(appearance.colorPalette.mediaSliderHeader)
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
    @State private var player: AVPlayer?
    @Binding var isPlaying : Bool
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    
    var body: some View {
        
        ZStack(alignment: .bottomLeading) {
            if data.customType == ISMChatMediaType.Video.value {
                ZStack{
                    VideoPlayer(player: player)
                        .onAppear {
                            // Initialize the player when the view appears
                            player = AVPlayer(url: URL(string: data.mediaUrl) ?? URL(fileURLWithPath: ""))
                            player?.pause() // Start paused
                        }
                        .onDisappear {
                            // Pause and remove the player when leaving the view
                            player?.pause()
                            player = nil
                        }.onChange(of: isPlaying, { _, _ in
                            if isPlaying {
                                player?.play()
                            } else {
                                player?.pause()
                            }
                        })
                    
                    Button {
                        isPlaying.toggle()
                    } label: {
                        if !isPlaying{
                            appearance.images.playVideo
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.white)
                                .shadow(radius: 10)
                                .padding()
                        }
                    }
                }
            } else if data.customType == ISMChatMediaType.gif.value {
                AnimatedImage(url: URL(string: data.mediaUrl))
                    .resizable()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ISMChatImageCahcingManger.networkImage(url: data.mediaUrl, isprofileImage: false)
                    .resizable()
                    .scaledToFit()
                    .modifier(ImageModifier(contentSize: CGSize(width: proxy.size.width, height: proxy.size.height)))
            }
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


// ShareSheet View
struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]
    var activities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: activities)
        controller.modalPresentationStyle = .pageSheet
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No update needed
    }
}
