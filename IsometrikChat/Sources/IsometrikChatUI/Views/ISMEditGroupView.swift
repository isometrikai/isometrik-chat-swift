//
//  ISMEditGroup.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 27/07/23.
//

import SwiftUI
import IsometrikChat

struct ISMEditGroupView: View {
    
    //MARK: - PROPERTIES
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var imageUrl : String?
    @State private var showSheet = false
    @State private var image : [UIImage] = []
    @State private var selectedMedia : [URL] = []
    @ObservedObject var viewModel = ChatsViewModel(ismChatSDK: ISMChatSdk.getInstance())
    @ObservedObject var conversationViewModel = ConversationViewModel(ismChatSDK: ISMChatSdk.getInstance())
    @State private var groupName = ""
    var existingGroupName : String
    var existingImage : String
    var conversationId : String?
    @Binding var updateData : Bool
    @State private var NameAlert : Bool = false
    @FocusState private var isFocused: Bool
    @State var themeFonts = ISMChatSdkUI.getInstance().getAppAppearance().appearance.fonts
    @State var themeColor = ISMChatSdkUI.getInstance().getAppAppearance().appearance.colorPalette
    @State var themeImage = ISMChatSdkUI.getInstance().getAppAppearance().appearance.images
    
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
                            .font(themeFonts.messageList_MessageText)
                            .foregroundColor(themeColor.userProfile_editText)
                    })
                }
                
                TextField("Write your group name", text: $groupName)
                    .padding()
                    .frame( height: 50)
                    .font(themeFonts.messageList_MessageText)
                    .foregroundColor(themeColor.messageList_MessageText)
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
                                .font(themeFonts.navigationBar_Title)
                                .foregroundColor(themeColor.navigationBar_Title)
                        }
                    }
                }
                .navigationBarBackButtonHidden(true)
                .navigationBarItems(leading: navBarLeadingBtn, trailing: navBarTrailingBtn)
                .sheet(isPresented: $showSheet) {
                    //            ImagePicker(image: $image, isShown: self.$showSheet, sourceType: .photoLibrary)
                    ISMMediaPickerView(selectedMedia: $selectedMedia, selectedProfilePicture: $image, isProfile: true)
                }
                .onAppear{
                    groupName = existingGroupName
                    imageUrl = existingImage
                    isFocused = true
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
                .font(themeFonts.messageList_MessageText)
                .foregroundColor(groupName != "" || image.count != 0 ? themeColor.userProfile_editText : Color.gray)
        }
    }
    
    var navBarLeadingBtn: some View {
        Button {
            presentationMode.wrappedValue.dismiss()
        } label: {
            themeImage.backButton
                .resizable()
                .frame(width: 29, height: 29, alignment: .center)
        }
    }
    
    func editGroup(){
        if !groupName.isEmpty{
            if existingGroupName != groupName{
                if let image = image.first{
                    viewModel.updateGroupTitle(title: groupName, conversationId: conversationId ?? "") { _ in
                        conversationViewModel.getPredefinedUrlToUpdateProfilePicture(image: image) { value in
                            viewModel.updateGroupImage(image: value ?? "", conversationId: conversationId ?? "") { _ in
                                updateData = true
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }
                }else{
                    viewModel.updateGroupTitle(title: groupName, conversationId: conversationId ?? "") { _ in
                        updateData = true
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }else{
                if let image = image.first{
                    conversationViewModel.getPredefinedUrlToUpdateProfilePicture(image: image) { value in
                        viewModel.updateGroupImage(image: value ?? "", conversationId: conversationId ?? "") { _ in
                            updateData = true
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }else{
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }else{
            NameAlert = true
        }
    }
}
