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
import ExyteMediaPicker


public struct ISMMediaUpload : Hashable {
    public var url : URL
    public var caption : String
    public var isVideo: Bool
}

struct ISMMediaEditor: View {
    
    //MARK:  - PROPERTIES
    @State public var selectedIndex = 0
    @Binding public var media : [Media]
    @Environment(\.dismiss) var dismiss
    @State public var scale: CGFloat = 1.0
    @State public var height: CGFloat = 32.0
    public var sendToUser : String
    @State public var showCropper : Bool = false
    @State public var navigateToDraw : Bool = false
    @State public var addText : Bool = false
    
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    @Binding var caption : String
    var onSend: () -> Void
    
    //MARK:  - LIFECYCLE
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            VStack {
                HStack(spacing: 10){
                    Button(action: {
                        dismiss()
                    }) {
                        appearance.images.mediaEditorCancel
                            .resizable()
                            .frame(width: 36, height: 36, alignment: .center)
                    }
                    
                    Spacer()
                    
//                    if media.count > 0{
//                        if media[selectedIndex].type != .video{
//                            Button(action: {
//                                showCropper = true
//                            }) {
//                                appearance.images.mediaEditorCrop
//                                    .resizable()
//                                    .frame(width: 36, height: 36, alignment: .center)
//                            }
//                            
//                            
//                            Button(action: {
//                                addText = true
//                            }) {
//                                appearance.images.mediaEditorText
//                                    .resizable()
//                                    .frame(width: 36, height: 36, alignment: .center)
//                            }
//                            
//                            Button(action: {
//                                navigateToDraw = true
//                            }) {
//                                appearance.images.mediaEditorEdit
//                                    .resizable()
//                                    .frame(width: 36, height: 36, alignment: .center)
//                            }
//                        }
//                    }
                }.padding(.horizontal,15).padding(.vertical,15)
                GeometryReader { proxy in
                    TabView(selection: $selectedIndex) {
                        ForEach(Array(media.enumerated()), id: \.element.id) { index, media in
                            VStack {
                                MediaCell(viewModel: MediaCellViewModel(media: media))
                                    .aspectRatio(1, contentMode: .fill)
                            }
                            .tag(index)
                        }
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                Spacer().frame(height: 150)
            }
            VStack{
                Spacer()
                LazyHStack(spacing: 10) {
                    ForEach(Array(media.enumerated()), id: \.element.id) { index, media in
                        ZStack {
                            MediaEditorCell(viewModel: MediaCellViewModel(media: media), selectedIndex: selectedIndex)
                                .frame(width: 46, height: 46) // Ensure that the image and border have the same frame
                                .cornerRadius(8) // Make sure this is added to the main frame
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(lineWidth: 2)
                                        .foregroundColor(selectedIndex == index ? Color.white : Color.clear)
                                )
                                .overlay(
                                    LinearGradient(gradient: Gradient(colors: selectedIndex == index ? [Color.gray.opacity(0.6), Color.clear] : [Color.clear, Color.clear]), startPoint: .leading, endPoint: .trailing)
                                        .frame(width: 46, height: 46) // Match the size of the image
                                        .cornerRadius(8) // Match the corner radius to the main image
                                        .offset(x: 5)
                                )
                                .onTapGesture {
                                    if selectedIndex == index {
                                        // Delete action
                                        if self.media.count == 1 {
                                            self.media.removeAll()
                                            dismiss()
                                        } else {
                                            self.media.remove(at: index)
                                            // Adjust selectedIndex after deletion
                                            if selectedIndex >= self.media.count {
                                                selectedIndex = self.media.count - 1
                                            }
                                        }
                                    } else {
                                        selectedIndex = index
                                    }
                                }
                            
                            // Trash icon, only shown when selected
                            if selectedIndex == index {
                                Image(systemName: "trash")
                                    .foregroundColor(.white)
                                    .frame(width: 31, height: 33)
                            }
                        }
                    }
                }
                .frame(height: 55) // Set the height of the entire LazyHStack

                
                if selectedIndex <= (media.count - 1){
                    HStack(spacing: 15) {
                        
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "plus.square.on.square")
                                .resizable()
                                .frame(width: 15,height: 15)
                                .foregroundColor(Color.white)
                        }
                        
                        TextField("", text: $caption,  axis: .vertical)
                            .accentColor(.white)
                            .lineLimit(1...10)
                            .font(appearance.fonts.messageListTextViewText)
                            .foregroundColor(Color.white)
                            .background(Color.black)
                            .overlay(
                                    alignment: .leading, // Aligns overlay content to leading
                                    content: {
                                        if caption.isEmpty {
                                            Text("Add a caption...")
                                                .font(appearance.fonts.messageListTextViewText)
                                                .foregroundColor(.white)
                                        }
                                    }
                                )
                    }
                    .padding(.vertical,10)
                    .padding(.horizontal,16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .padding(.horizontal,15)
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
                    
                    Button(action: {onSend()}) {
                        appearance.images.sendMedia
                            .resizable()
                            .frame(width: 36, height: 36, alignment: .center)
                    }
                }.padding(.bottom,20).padding(.horizontal,15)
            }
        }
//        .sheet(isPresented: $showCropper, content: {
//            ISMImageCropper(imageUrl: $media[selectedIndex].url, isShowing: $showCropper)
//        })
//        .fullScreenCover(isPresented: $navigateToDraw, content: {
//            ISMImageDraw(url: $media[selectedIndex].url, isShowing: $navigateToDraw)
//        })
//        .fullScreenCover(isPresented: $addText, content: {
//            ISMImageText(url: $media[selectedIndex].url, isShowing: $addText)
//        })
        .onChange(of: selectedIndex, { _, _ in
            print("selected Index ---> \(selectedIndex)")
        })
        .onAppear(perform: {
            print("selected Index ---> \(selectedIndex)")
            print(media)
        })
        .onTapGesture {
            dismissKeyboard()
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    //MARK: - CONFIGURE
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
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


struct MediaCell: View {
    @StateObject var viewModel: MediaCellViewModel
    @ObservedObject var keyboardHeightHelper = ISMKeyboardHeightHelper.shared

    var body: some View {
        GeometryReader { g in
            Group {
                if let image = viewModel.image {
                    let useFill = g.size.width / g.size.height > image.size.width / image.size.height
                    ISMZoomableScrollView {
                        imageView(image: image, useFill: useFill)
                    }
                } else if let player = viewModel.player {
                    let useFill = g.size.width / g.size.height > viewModel.videoSize.width / viewModel.videoSize.height
                    ISMZoomableScrollView {
                        videoView(player: player, useFill: useFill)
                    }
                } else {
                    ProgressView()
                        .tint(.white)
                }
            }
            .allowsHitTesting(!keyboardHeightHelper.keyboardDisplayed)
            .position(x: g.frame(in: .local).midX, y: g.frame(in: .local).midY)
        }
        .task {
            await viewModel.onStart()
        }
        .onDisappear {
            viewModel.onStop()
        }
    }
    @ViewBuilder
    func imageView(image: UIImage, useFill: Bool) -> some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit) // Use .fit to prevent zooming
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped() // Optional: ensures the image does not exceed the view bounds
    }

    func videoView(player: AVPlayer, useFill: Bool) -> some View {
        PlayerView(player: player, bgColor: .black, useFill: useFill)
            .disabled(true)
            .overlay {
                ZStack {
                    Color.clear
                    if !viewModel.isPlaying {
                        Image(systemName: "play.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    viewModel.togglePlay()
                }
            }
    }
}

struct PlayerView: UIViewRepresentable {

    var player: AVPlayer
    var bgColor: Color
    var useFill: Bool

    func makeUIView(context: Context) -> PlayerUIView {
        PlayerUIView(player: player, bgColor: bgColor, useFill: useFill)
    }

    func updateUIView(_ uiView: PlayerUIView, context: UIViewRepresentableContext<PlayerView>) {
        uiView.playerLayer.player = player
        uiView.playerLayer.videoGravity = useFill ? .resizeAspectFill : .resizeAspect
    }
}

class PlayerUIView: UIView {

    // MARK: Class Property

    let playerLayer = AVPlayerLayer()

    // MARK: Init

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(player: AVPlayer, bgColor: Color, useFill: Bool) {
        super.init(frame: .zero)
        self.playerSetup(player: player, bgColor: bgColor, useFill: useFill)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Life-Cycle

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }

    // MARK: Class Methods

    private func playerSetup(player: AVPlayer, bgColor: Color, useFill: Bool) {
        playerLayer.player = player
        playerLayer.videoGravity = useFill ? .resizeAspectFill : .resizeAspect
        player.actionAtItemEnd = .none
        layer.addSublayer(playerLayer)
        playerLayer.backgroundColor = bgColor.cgColor
    }
}


struct MediaEditorCell: View {

    @StateObject var viewModel: MediaCellViewModel
    let selectedIndex : Int

    var body: some View {
        GeometryReader { g in
            VStack {
                if let url = viewModel.imageUrl {
                    AsyncImage(url: url) { phase in
                        if case let .success(image) = phase {
                            image
                                .resizable()
                                .scaledToFill()
                        }
                    }
                } else if let videourl = viewModel.videoThumbnailUrl {
                    AsyncImage(url: videourl) { phase in
                        if case let .success(image) = phase {
                            image
                                .resizable()
                                .scaledToFill()
                        }
                    }
                } else {
                    ProgressView()
                }
            }
        }
        .task {
            await viewModel.onStart()
        }
        .onDisappear {
            viewModel.onStop()
        }
    }
}


final class MediaCellViewModel: ObservableObject {

    let media: Media

    @Published var imageUrl: URL? = nil
    @Published var videoThumbnailUrl: URL? = nil
    @Published var player: AVPlayer? = nil
    @Published var image: UIImage? = nil
    @Published var isPlaying = false
    @Published var videoSize: CGSize = .zero

    init(media: Media) {
        self.media = media
    }

    func onStart() async {
            guard imageUrl == nil || player == nil else { return }

            // Fetch the URLs asynchronously
            let url = await media.getURL()
            guard let url = url else { return }

            let videothumbnail = await media.getThumbnailURL()
            guard let videothumbnail = videothumbnail else { return }

            // Now, update the UI on the main thread
            DispatchQueue.main.async {
                switch self.media.type {
                case .image:
                    Task {
                        let data = try? await self.media.getData()
                        guard let data = data else { return }
                        
                        DispatchQueue.main.async {
                            self.image = UIImage(data: data)
                            self.imageUrl = url
                        }
                    }
                case .video:
                    Task {
                        let videoSize = await ISMChatHelper.getVideoSize(url)
                        DispatchQueue.main.async {
                            self.player = AVPlayer(url: url)
                            self.videoThumbnailUrl = videothumbnail
                            self.videoSize = videoSize
                        }
                    }
                }
            }
        }

    func togglePlay() {
        if isPlaying {
            player?.pause()
        } else {
            player?.play()
        }
        isPlaying = !isPlaying
    }

    func onStop() {
        imageUrl = nil
        player = nil
        isPlaying = false
    }
}
