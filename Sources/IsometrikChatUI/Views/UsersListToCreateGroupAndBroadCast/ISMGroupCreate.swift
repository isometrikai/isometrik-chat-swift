//
//  ISMGroupCreate.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 23/10/23.
//

import SwiftUI
import IsometrikChat

public struct ISMGroupCreate: View {
    
    //MARK: - PROPERTIES
    @Environment(\.dismiss) public var dismiss
    @Binding public var showSheetView : Bool
    @Binding public var userSelected : [ISMChatUser]
    @State public var showSheet = false
    @State public var cancelPicker : Bool = false
    @State public var image : [UIImage] = []
    @State public var selectedMedia : [URL] = []
    public var viewModel = ConversationViewModel()
    public var chatViewModel = ChatsViewModel()
    @State public var groupNameAlert : Bool = false
    @State public var groupName = ""
    @State public var hasCreatedGroup = false
    public let profileImage = "https://res.cloudinary.com/dxkoc9aao/image/upload/v1616075844/kesvhgzyiwchzge7qlsz_yfrh9x.jpg"
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    @State public var userData = ISMChatSdk.getInstance().getChatClient().getConfigurations().userConfig
    
    
    
    //MARK: - BODY
    
    public var body: some View {
        ZStack{
            VStack{
                List {
                    HeaderView()
                    Section(header: participants()) {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 8) {
                            ForEach(userSelected, id: \.self) { user in
                                VStack(spacing: 3){
                                    ZStack(alignment: .topTrailing) {
                                        UserAvatarView(avatar: user.userProfileImageUrl ?? "", showOnlineIndicator: false,size: CGSize(width: 48, height: 48), userName: user.userName ?? "",font: .regular(size: 16))
                                        appearance.images.removeUserFromSelectedFromList
                                            .resizable()
                                            .foregroundColor(.white)
                                            .frame(width: 20, height: 20)
                                    }
                                    
                                    Text(user.userName ?? "")
                                        .font(appearance.fonts.chatListUserMessage)
                                        .foregroundColor(appearance.colorPalette.chatListUserMessage)
                                        .lineLimit(2)
                                }.onTapGesture {
                                    if userSelected.contains(where: { user1 in
                                        user1.id == user.id
                                    }){
                                        userSelected.removeAll(where: { $0.id == user.id })
                                    }
                                }.frame(width: 60, height: 60, alignment: .center)
                            }
                        }.background(.clear)
                    }.background(.clear)
                    
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text("New Group")
                            .font(appearance.fonts.navigationBarTitle)
                            .foregroundColor(appearance.colorPalette.navigationBarTitle)
                    }
                }
            }
            .navigationBarItems(leading: navBarLeadingBtn, trailing: navBarTrailingBtn)
            .fullScreenCover(isPresented: $showSheet, content: {
                ISMMediaPickerView(selectedMedia: $selectedMedia, selectedProfilePicture: $image, isProfile: true)
            })
            
            
            if groupNameAlert == true{
                Text("Enter Group Name.")
                    .font(Font.caption)
                    .padding()
                    .background(.black.opacity(0.4))
                    .foregroundColor(.white)
                    .cornerRadius(5)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            groupNameAlert = false
                        }
                    }
            }
        }
    }
    
    //MARK: - CONFIGURE
    func participants() -> some View{
        HStack{
            Text("MEMBERS: \(userSelected.count)")
        }
    }
    
    func HeaderView() -> some View{
        HStack{
            if let image = self.image.first{
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 36, height: 36, alignment: .center)
                    .clipShape(Circle())
                    .onTapGesture {
                        showSheet = true
                    }
            }else{
                HStack{
                    appearance.images.addMembers
                        .resizable()
                        .frame(width: 36, height: 36)
                        .onTapGesture {
                            showSheet = true
                        }
                    
                }
            }
            
            TextField("Group Name*", text: $groupName)
                .font(appearance.fonts.messageListMessageText)
                .foregroundColor(appearance.colorPalette.messageListHeaderTitle)
            
            
            Spacer()
            
            if !groupName.isEmpty{
                Button {
                    groupName = ""
                } label: {
                    appearance.images.removeSearchText
                        .tint(appearance.colorPalette.messageListReplyToolbarRectangle)
                }.frame(width: 30)
            }
            
        }.padding(.vertical)
    }
    
    var navBarTrailingBtn: some View {
        VStack{
            Button(action: {
                if !self.groupName.isEmpty{
                    //check not to create multiple groups
                    if !hasCreatedGroup{
                        createGroup()
                        hasCreatedGroup = true
                    }
                }else{
                    groupNameAlert = true
                }
            }) {
                Text("Create")
                    .font(appearance.fonts.messageListMessageText)
                    .foregroundColor(userSelected.count > 0 ? appearance.colorPalette.userProfileEditText : .gray)
            }
        }
    }
    
    var navBarLeadingBtn: some View {
        Button(action: { dismiss() }) {
            appearance.images.backButton
                .resizable()
                .frame(width: appearance.imagesSize.backButton.width, height: appearance.imagesSize.backButton.height)
        }
    }
    
    func createGroup(){
        //create grp API
        let member = userSelected.map { $0.id }
        if let image = image.first{
            if !self.groupName.isEmpty{
                chatViewModel.isBusy = true
                chatViewModel.uploadConversationImage(image: image, conversationType: 0, newConversation: true, conversationId: "", conversationTitle: self.groupName){ url in
                    chatViewModel.createGroup(members: member, groupTitle: self.groupName, groupImage: url ?? "") { data in
                        NotificationCenter.default.post(name: NSNotification.refreshConvList,
                                                        object: nil)
                        showSheetView = false
                    }
                }
            }else{
                groupNameAlert = true
            }
        }else{
            if !self.groupName.isEmpty{
                chatViewModel.isBusy = true
                chatViewModel.createGroup(members: member, groupTitle: self.groupName, groupImage: profileImage) { data in
                    NotificationCenter.default.post(name: NSNotification.refreshConvList,
                                                    object: nil)
                    showSheetView = false
                }
            }else{
                groupNameAlert = true
            }
        }
    }
}
