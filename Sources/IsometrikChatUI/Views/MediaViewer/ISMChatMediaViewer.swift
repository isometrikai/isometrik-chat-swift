//
//  SwiftUIView.swift
//  
//
//  Created by Rasika Bharati on 19/09/24.
//

import SwiftUI
import IsometrikChat
import AVKit

/// A SwiftUI view that displays media content (images/videos) in a full-screen viewer
/// with gesture-based dismissal, sharing capabilities, and thumbnail navigation.
struct ISMChatMediaViewer : View {
    // MARK: - Properties
    
    /// View model that handles the media viewer's business logic and state
    @StateObject var viewModel: ISMChatMediaViewerViewModel
    /// Closure called when the viewer should be closed
    var onClose: () -> Void
    /// UI appearance configuration from the SDK
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    /// Controls the visibility of the share sheet
    @State var isShareSheetPresented : Bool = false
    /// Controls video playback state
    @State var toggleVideo : Bool = false
    /// Controls navigation to media detail view
    @State var navigatetoMedia : Bool = false

    var body: some View {
        // Configure dismissal gesture that tracks vertical drag
        let closeGesture = DragGesture()
            .onChanged { viewModel.offset = closeSize(from: $0.translation) }
            .onEnded {
                withAnimation {
                    viewModel.offset = .zero
                }
                // Dismiss viewer if dragged down more than 100 points
                if $0.translation.height >= 100 {
                    onClose()
                }
            }

        ZStack {
            Color.white
                .opacity(max((200.0 - viewModel.offset.height) / 200.0, 0.5))
            VStack{
                headerView().padding(.horizontal,15)
                ZStack{
                    VStack {
                        TabView(selection: $viewModel.index) {
                            ForEach(viewModel.attachments.enumerated().map({ $0 }), id: \.offset) { (index, attachment) in
                                ISMChatMediaView(attachment: attachment)
                                    .tag(index)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .allowsHitTesting(false)
                            }
                        }
                        .environmentObject(viewModel)
                        .tabViewStyle(.page(indexDisplayMode: .never))
                    }
                    .offset(viewModel.offset)
                    .gesture(closeGesture)
                    .onTapGesture {
                        withAnimation {
                            viewModel.showMinis.toggle()
                        }
                    }

                    VStack {
                        Spacer()
                        ScrollViewReader { proxy in
                            if viewModel.showMinis {
                                ScrollView(.horizontal) {
                                    HStack(spacing: 2) {
                                        ForEach(viewModel.attachments.enumerated().map({ $0 }), id: \.offset) { (index, attachment) in
                                            ISMChatAttachmentCell(attachment: attachment) { _ in
                                                withAnimation {
                                                    viewModel.index = index
                                                }
                                            }
                                            .frame(width: 25, height: 50)
                                            .cornerRadius(4)
                                            .clipped()
                                            .id(index)
                                            .overlay {
                                                if viewModel.index == index {
                                                    RoundedRectangle(cornerRadius: 4)
                                                        .stroke(Color.white, lineWidth: 2)
                                                }
                                            }
                                            .padding(.vertical, 1)
                                        }
                                    }
                                }
                                .padding([.vertical], 12)
                                .background(Color.clear)
                                .onAppear {
                                    proxy.scrollTo(viewModel.index)
                                }
                                .onChange(of: viewModel.index) { _, newValue in
                                    withAnimation {
                                        proxy.scrollTo(newValue, anchor: .center)
                                    }
                                }
                            }
                        }
                    }
                    .offset(viewModel.offset)
                }
                footerView().padding(.bottom,15).padding(.top,5)
            }
            .sheet(isPresented: $isShareSheetPresented) {
                ShareSheet(items: [viewModel.attachments[viewModel.index].mediaUrl])
                    .presentationDetents([.fraction(0.5)])
            }
        }
    }
    
    /// Builds the header view containing close button and media metadata
    func headerView() -> some View{
        ZStack(alignment: .center){
            HStack{
                Button(action: onClose) {
                    appearance.images.CloseSheet
                        .resizable()
                        .frame(width: 18, height: 18)
                }
                Spacer()
            }
            VStack(spacing:2) {
                let date = NSDate().doubletoDate(time: viewModel.attachments[viewModel.index].sentAt)
                let time = NSDate().doubletoTime(time: viewModel.attachments[viewModel.index].sentAt)
                let name = viewModel.attachments[viewModel.index].userName == ISMChatSdk.getInstance().getChatClient()?.getConfigurations().userConfig.userName ? ConstantStrings.you : viewModel.attachments[viewModel.index].userName
                Text(name)
                    .font(appearance.fonts.mediaSliderHeader)
                    .foregroundColor(appearance.colorPalette.mediaSliderHeader)
                Text("\(date), \(time)")
                    .font(appearance.fonts.mediaSliderDescription)
                    .foregroundColor(appearance.colorPalette.mediaSliderDescription)
            }
        }
    }
    
    /// Builds the footer view containing media controls and action buttons
    func footerView() -> some View{
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
            if ISMChatHelper.isVideoString(media: viewModel.attachments[viewModel.index].mediaUrl){
                Spacer()
                Button {
                    viewModel.toggleVideoPlaying()
                } label: {
                    Image(systemName: viewModel.videoPlaying ? "pause.fill"  : "play.fill")
                        .resizable() // Makes the image resizable
                        .aspectRatio(contentMode: .fit) // Maintains the aspect ratio of the image
                        .frame(width: 20, height: 20) // Set the desired width and height
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                Button(action: { 
                    viewModel.toggleVideoMuted()
                }, label: {
                    Image(systemName: viewModel.videoMuted ?  "speaker.slash" : "speaker.wave.3.fill")
                        .resizable() // Makes the image resizable
                        .aspectRatio(contentMode: .fit) // Maintains the aspect ratio of the image
                        .frame(width: 20, height: 20) // Set the desired width and height
                        .foregroundColor(.black)
                })
            }
                
            
            Spacer()
            Button {
                ISMChatHelper.downloadMedia(from: viewModel.attachments[viewModel.index].mediaUrl)
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
        .padding(.horizontal, 15)
    }
}

// MARK: - Private Extensions

private extension ISMChatMediaViewer {
    /// Calculates the size for the close gesture, ensuring vertical movement only
    /// - Parameter size: The translation size from the drag gesture
    /// - Returns: A CGSize with only vertical movement
    func closeSize(from size: CGSize) -> CGSize {
        CGSize(width: 0, height: max(size.height, 0))
    }
}

/// A UIViewControllerRepresentable wrapper for UIActivityViewController to enable sharing
struct ShareSheet: UIViewControllerRepresentable {
    /// Items to be shared
    var items: [Any]
    /// Optional custom activities
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
