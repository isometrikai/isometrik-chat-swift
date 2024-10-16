//
//  ISMEditGroup.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 27/07/23.
//

import SwiftUI
import IsometrikChat
import ExyteMediaPicker

struct ISMEditGroupView: View {
    
    //MARK: - PROPERTIES
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var imageUrl : String?
    @State private var showSheet = false
    @State private var showCamera = false
    @State private var showGallery = false
    @State var cameraImageToUse : URL?
    @State public var uploadMedia : Bool = false
    @State private var image : [UIImage] = []
    @State private var selectedMedia : [URL] = []
    @ObservedObject var viewModel = ChatsViewModel()
    @ObservedObject var conversationViewModel = ConversationViewModel()
    @State private var groupName = ""
    var existingGroupName : String
    var existingImage : String
    var conversationId : String?
    @State private var NameAlert : Bool = false
    @FocusState private var isFocused: Bool
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    @State var showProgressView : Bool = false
    
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
    
    func editGroup(){
        if !groupName.isEmpty{
            showProgressView = true
            if existingGroupName != groupName{
                if let image = image.first{
                    viewModel.updateGroupTitle(title: groupName, conversationId: conversationId ?? "") { _ in
                        updategroupImage(image: image)
                    }
                }else{
                    viewModel.updateGroupTitle(title: groupName, conversationId: conversationId ?? "") { _ in
                        NotificationCenter.default.post(name: NSNotification.updateGroupInfo, object: nil, userInfo: nil)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }else{
                if let image = image.first{
                    updategroupImage(image: image)
                }else if let imageUrl = cameraImageToUse{
                    updategroupImageUrl(imageUrl: imageUrl)
                }else{
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }else{
            NameAlert = true
        }
    }
    
    func updategroupImageUrl(imageUrl : URL){
        viewModel.uploadConversationUrl(url:imageUrl , conversationType: 0, newConversation: false, conversationId: conversationId ?? "", conversationTitle: groupName) { value in
            viewModel.updateGroupImage(image: value ?? "", conversationId: conversationId ?? "") { _ in
                NotificationCenter.default.post(name: NSNotification.updateGroupInfo, object: nil, userInfo: nil)
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    func updategroupImage(image : UIImage){
        viewModel.uploadConversationImage(image: image, conversationType: 0, newConversation: false, conversationId: conversationId ?? "", conversationTitle: groupName) { value in
            viewModel.updateGroupImage(image: value ?? "", conversationId: conversationId ?? "") { _ in
                NotificationCenter.default.post(name: NSNotification.updateGroupInfo, object: nil, userInfo: nil)
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}
