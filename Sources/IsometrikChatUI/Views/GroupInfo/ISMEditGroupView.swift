//
//  ISMEditGroup.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 27/07/23.
//

import SwiftUI
import IsometrikChat
import ExyteMediaPicker

/// A view that allows users to edit group information including name and profile picture
/// Supports camera, gallery selection and image removal functionality
struct ISMEditGroupView: View {
    
    //MARK: - PROPERTIES
    // View presentation and navigation
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    // Media selection and handling states
    @State var imageUrl: String?
    @State private var showSheet = false
    @State private var showCamera = false
    @State private var showGallery = false
    @State var cameraImageToUse: URL?
    @State public var uploadMedia: Bool = false
    @State private var image: [UIImage] = []
    @State private var selectedMedia: [URL] = []
    
    // View Models
    @ObservedObject var viewModel = ChatsViewModel()
    @ObservedObject var conversationViewModel = ConversationViewModel()
    
    // Group information states
    @State private var groupName = ""
    var existingGroupName: String
    var existingImage: String
    var conversationId: String?
    
    // UI States
    @State private var NameAlert: Bool = false
    @FocusState private var isFocused: Bool
    @State var showProgressView: Bool = false
    @State var removeImage: Bool = false
    
    // Appearance configuration
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    @ObservedObject var viewModelNew: ConversationsViewModel
    
    //MARK: - BODY
    var body: some View {
        ZStack{
            Color.backgroundView.edgesIgnoringSafeArea(.all)
            VStack(spacing: 20){
                VStack(spacing: 10){
                    
                    if let image = image.first{
                        Image(uiImage: image)
                            .resizable()
                            .clipShape(Circle())
                            .frame(width: 120, height: 120)
                            .onTapGesture {
                                showSheet = true
                            }
                    }else if let url = cameraImageToUse{
                        UserAvatarView(avatar: url.absoluteString, showOnlineIndicator: false,size: CGSize(width: 120, height: 120), userName: existingGroupName,font: .regular(size: 30))
                            .onTapGesture {
                                showSheet = true
                            }
                    }else{
                        UserAvatarView(avatar: imageUrl ?? "", showOnlineIndicator: false,size: CGSize(width: 120, height: 120), userName: existingGroupName,font: .regular(size: 30))
                            .onTapGesture {
                                showSheet = true
                            }
                    }
                    
                    Button(action: {
                        showSheet = true
                    }, label: {
                        Text("Edit")
                            .font(appearance.fonts.messageListMessageText)
                            .foregroundColor(appearance.colorPalette.userProfileEditText)
                    })
                }
                
                TextField("Write your group name", text: $groupName)
                    .padding()
                    .frame( height: 50)
                    .font(appearance.fonts.messageListMessageText)
                    .foregroundColor(appearance.colorPalette.messageListHeaderTitle)
                    .keyboardType(.default)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.words)
                    .background(Color.white)
                    .cornerRadius(10)
                    .focused($isFocused)
                
                Spacer()
            }.padding()
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        VStack {
                            Text("Edit Group")
                                .font(appearance.fonts.navigationBarTitle)
                                .foregroundColor(appearance.colorPalette.navigationBarTitle)
                        }
                    }
                }
                .navigationBarBackButtonHidden(true)
                .navigationBarItems(leading: navBarLeadingBtn, trailing: navBarTrailingBtn)
                .confirmationDialog("", isPresented: $showSheet, titleVisibility: .hidden) {
                    VStack {
                        Button(action: {
                            showCamera.toggle()
                        }, label: {
                            Text("Camera")
                        })
                        
                        Button(action: {
                            showGallery.toggle()
                        }, label: {
                            Text("Gallery")
                        })
                        
                        Button(action: {
                            removeImage = true
                        }, label: {
                            Text("Remove")
                        })
                    }
                }
                .sheet(isPresented: $showGallery) {
                    ISMMediaPickerView(selectedMedia: $selectedMedia, selectedProfilePicture: $image, isProfile: true)
                }
                .sheet(isPresented: $showCamera) {
                    ISMCameraView(media : $cameraImageToUse, isShown: $showCamera, uploadMedia: $uploadMedia, mediaType: .image)
                }
                .onAppear{
                    groupName = existingGroupName
                    imageUrl = existingImage
                    isFocused = true
                }
                .onChange(of: removeImage) { oldValue, newValue in
                    if removeImage == true{
                        removeImageInApi()
                        removeImage = false
                    }
                }
            
            if showProgressView == true{
                ProgressView()
            }
            
            if NameAlert == true{
                Text("Group name can't be empty")
                    .font(Font.caption)
                    .padding()
                    .background(.black.opacity(0.4))
                    .foregroundColor(.white)
                    .cornerRadius(5)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            NameAlert = false
                        }
                    }
            }
        }
    }
    
    //MARK: - CONFIGURE
    var navBarTrailingBtn: some View {
        Button {
            editGroup()
        } label: {
            Text("Done")
                .font(appearance.fonts.messageListMessageText)
                .foregroundColor(groupName != "" || image.count != 0 ? appearance.colorPalette.userProfileEditText : Color.gray)
        }
    }
    
    var navBarLeadingBtn: some View {
        Button {
            presentationMode.wrappedValue.dismiss()
        } label: {
            appearance.images.backButton
                .resizable()
                .frame(width: appearance.imagesSize.backButton.width, height: appearance.imagesSize.backButton.height)
        }
    }
    
    //MARK: - Group Edit Functions
    
    /// Handles the group editing process including name and image updates
    /// Validates group name and manages different update scenarios
    func editGroup() {
        // Validate group name is not empty
        if !groupName.isEmpty {
            showProgressView = true
            
            // Case 1: Group name has changed
            if existingGroupName != groupName {
                if let image = image.first {
                    // Update both name and image
//                    viewModel.updateGroupTitle(title: groupName, conversationId: conversationId ?? "") { _ in
//                        updategroupImage(image: image)
//                    }
                    Task{
                        await viewModelNew.updateGroupTitle(title: groupName, conversationId: conversationId ?? "", localOnly: false)
                        updategroupImage(image: image)
                    }
                } else {
                    // Update name only
                    Task{
                        await viewModelNew.updateGroupTitle(title: groupName, conversationId: conversationId ?? "", localOnly: false)
                        NotificationCenter.default.post(name: NSNotification.updateGroupInfo, object: nil, userInfo: nil)
                        presentationMode.wrappedValue.dismiss()
                    }
//                    viewModel.updateGroupTitle(title: groupName, conversationId: conversationId ?? "") { _ in
//                        NotificationCenter.default.post(name: NSNotification.updateGroupInfo, object: nil, userInfo: nil)
//                        presentationMode.wrappedValue.dismiss()
//                    }
                }
            } else {
                // Case 2: Only image has changed
                if let image = image.first {
                    updategroupImage(image: image)
                } else if let imageUrl = cameraImageToUse {
                    updategroupImageUrl(imageUrl: imageUrl)
                } else {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        } else {
            NameAlert = true
        }
    }
    
    /// Removes the group image and sets it back to default
    func removeImageInApi() {
        let defaultImage = "https://res.cloudinary.com/dxkoc9aao/image/upload/v1616075844/kesvhgzyiwchzge7qlsz_yfrh9x.jpg"
//        viewModel.updateGroupImage(image: defaultImage, conversationId: conversationId ?? "") { _ in
//            NotificationCenter.default.post(name: NSNotification.updateGroupInfo, object: nil, userInfo: nil)
//            presentationMode.wrappedValue.dismiss()
//        }
        Task{
            await viewModelNew.updateGroupImage(image: defaultImage, conversationId: conversationId ?? "", localOnly: false)
            NotificationCenter.default.post(name: NSNotification.updateGroupInfo, object: nil, userInfo: nil)
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    /// Updates group image using a URL
    /// - Parameter imageUrl: URL of the new image
    func updategroupImageUrl(imageUrl: URL) {
        viewModel.uploadConversationUrl(url: imageUrl, conversationType: 0, newConversation: false, 
            conversationId: conversationId ?? "", conversationTitle: groupName) { value in
            Task{
                await viewModelNew.updateGroupImage(image: value ?? "", conversationId: conversationId ?? "", localOnly: false)
                NotificationCenter.default.post(name: NSNotification.updateGroupInfo, object: nil, userInfo: nil)
                presentationMode.wrappedValue.dismiss()
            }
//            viewModel.updateGroupImage(image: value ?? "", conversationId: conversationId ?? "") { _ in
//                NotificationCenter.default.post(name: NSNotification.updateGroupInfo, object: nil, userInfo: nil)
//                presentationMode.wrappedValue.dismiss()
//            }
        }
    }
    
    /// Updates group image using a UIImage
    /// - Parameter image: UIImage to be set as group image
    func updategroupImage(image: UIImage) {
        viewModel.uploadConversationImage(image: image, conversationType: 0, newConversation: false,
            conversationId: conversationId ?? "", conversationTitle: groupName) { value in
            Task{
                await viewModelNew.updateGroupImage(image: value ?? "", conversationId: conversationId ?? "", localOnly: false)
                NotificationCenter.default.post(name: NSNotification.updateGroupInfo, object: nil, userInfo: nil)
                presentationMode.wrappedValue.dismiss()
            }
//            viewModel.updateGroupImage(image: value ?? "", conversationId: conversationId ?? "") { _ in
//                NotificationCenter.default.post(name: NSNotification.updateGroupInfo, object: nil, userInfo: nil)
//                presentationMode.wrappedValue.dismiss()
//            }
        }
    }
}
