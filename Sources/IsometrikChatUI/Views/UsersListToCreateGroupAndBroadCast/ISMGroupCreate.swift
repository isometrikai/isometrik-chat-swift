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
    @Environment(\.dismiss) public var dismiss // Dismiss action for the view
    @Binding public var showSheetView : Bool // Binding to control the visibility of the sheet view
    @Binding public var userSelected : [ISMChatUser] // Binding for selected users
    @State public var showSheet = false // State to control media picker visibility
    @State public var cancelPicker : Bool = false // State to manage picker cancellation
    @State public var image : [UIImage] = [] // State to hold selected images
    @State public var selectedMedia : [URL] = [] // State to hold selected media URLs
    public var viewModel = ConversationViewModel() // ViewModel for conversation handling
    public var chatViewModel = ChatsViewModel() // ViewModel for chat handling
    @State public var groupNameAlert : Bool = false // State to show group name alert
    @State public var groupName = "" // State to hold the group name input
    @State public var hasCreatedGroup = false // State to prevent multiple group creations
    public let profileImage = "https://res.cloudinary.com/dxkoc9aao/image/upload/v1616075844/kesvhgzyiwchzge7qlsz_yfrh9x.jpg" // Default profile image URL
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance // Appearance settings
//    var userData = ISMChatSdk.getInstance().getChatClient()?.getConfigurations().userConfig
    
    
    
    //MARK: - BODY
    
    public var body: some View {
        ZStack{
            VStack{
                List {
                    HeaderView() // Display header view
                    Section(header: participants()) { // Display participants section
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 8) {
                            ForEach(userSelected, id: \.self) { user in
                                VStack(spacing: 3){
                                    ZStack(alignment: .topTrailing) {
                                        UserAvatarView(avatar: user.userProfileImageUrl ?? "", showOnlineIndicator: false,size: CGSize(width: 48, height: 48), userName: user.userName ?? "",font: .regular(size: 16)) // Display user avatar
                                        appearance.images.removeUserFromSelectedFromList // Icon to remove user from selection
                                            .resizable()
                                            .foregroundColor(.white)
                                            .frame(width: 20, height: 20)
                                    }
                                    
                                    Text(user.userName ?? "") // Display user name
                                        .font(appearance.fonts.chatListUserMessage)
                                        .foregroundColor(appearance.colorPalette.chatListUserMessage)
                                        .lineLimit(2)
                                }.onTapGesture {
                                    // Toggle user selection on tap
                                    if userSelected.contains(where: { user1 in
                                        user1.id == user.id
                                    }){
                                        userSelected.removeAll(where: { $0.id == user.id }) // Remove user from selection
                                    }
                                }.frame(width: 60, height: 60, alignment: .center)
                            }
                        }.background(.clear)
                    }.background(.clear)
                    
                }
            }
            .navigationBarBackButtonHidden(true) // Hide back button
            .navigationBarTitleDisplayMode(.inline) // Set title display mode
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text("New Group") // Title for the new group creation
                            .font(appearance.fonts.navigationBarTitle)
                            .foregroundColor(appearance.colorPalette.navigationBarTitle)
                    }
                }
            }
            .navigationBarItems(leading: navBarLeadingBtn, trailing: navBarTrailingBtn) // Navigation bar buttons
            .fullScreenCover(isPresented: $showSheet, content: {
                ISMMediaPickerView(selectedMedia: $selectedMedia, selectedProfilePicture: $image, isProfile: true) // Media picker for selecting images
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
                            groupNameAlert = false // Dismiss alert after 1.5 seconds
                        }
                    }
            }
        }
    }
    
    //MARK: - CONFIGURE
    func participants() -> some View{
        HStack{
            Text("MEMBERS: \(userSelected.count)") // Display count of selected members
        }
    }
    
    func HeaderView() -> some View{
        HStack{
            if let image = self.image.first{
                Image(uiImage: image) // Display selected image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 36, height: 36, alignment: .center)
                    .clipShape(Circle()) // Make image circular
                    .onTapGesture {
                        showSheet = true // Show media picker on tap
                    }
            }else{
                HStack{
                    appearance.images.addMembers // Icon to add members
                        .resizable()
                        .frame(width: 36, height: 36)
                        .onTapGesture {
                            showSheet = true // Show media picker on tap
                        }
                    
                }
            }
            
            TextField("Group Name*", text: $groupName) // Text field for group name input
                .font(appearance.fonts.messageListMessageText)
                .foregroundColor(appearance.colorPalette.messageListHeaderTitle)
            
            
            Spacer()
            
            if !groupName.isEmpty{
                Button {
                    groupName = "" // Clear group name on button tap
                } label: {
                    appearance.images.removeSearchText // Icon to remove text
                        .tint(appearance.colorPalette.messageListReplyToolbarRectangle)
                }.frame(width: 30)
            }
            
        }.padding(.vertical)
    }
    
    var navBarTrailingBtn: some View {
        VStack{
            Button(action: {
                // Create group if group name is not empty
                if !self.groupName.isEmpty{
                    // Check not to create multiple groups
                    if !hasCreatedGroup{
                        createGroup() // Call function to create group
                        hasCreatedGroup = true // Set flag to prevent multiple creations
                    }
                }else{
                    groupNameAlert = true // Show alert if group name is empty
                }
            }) {
                Text("Create") // Button to create group
                    .font(appearance.fonts.messageListMessageText)
                    .foregroundColor(userSelected.count > 0 ? appearance.colorPalette.userProfileEditText : .gray) // Change color based on selection
            }
        }
    }
    
    var navBarLeadingBtn: some View {
        Button(action: { dismiss() }) { // Button to dismiss the view
            appearance.images.backButton
                .resizable()
                .frame(width: appearance.imagesSize.backButton.width, height: appearance.imagesSize.backButton.height)
        }
    }
    
    func createGroup(){
        // Function to create a group
        let member = userSelected.map { $0.id } // Get selected user IDs
        if let image = image.first{
            // If an image is selected, upload it
            if !self.groupName.isEmpty{
                chatViewModel.isBusy = true // Set busy state
                chatViewModel.uploadConversationImage(image: image, conversationType: 0, newConversation: true, conversationId: "", conversationTitle: self.groupName){ url in
                    chatViewModel.createGroup(members: member, groupTitle: self.groupName, groupImage: url ?? "") { data in
                        NotificationCenter.default.post(name: NSNotification.refreshConvList, object: nil) // Notify to refresh conversation list
                        showSheetView = false // Dismiss the sheet view
                    }
                }
            }else{
                groupNameAlert = true // Show alert if group name is empty
            }
        }else{
            // If no image is selected, use default profile image
            if !self.groupName.isEmpty{
                chatViewModel.isBusy = true // Set busy state
                chatViewModel.createGroup(members: member, groupTitle: self.groupName, groupImage: profileImage) { data in
                    NotificationCenter.default.post(name: NSNotification.refreshConvList, object: nil) // Notify to refresh conversation list
                    showSheetView = false // Dismiss the sheet view
                }
            }else{
                groupNameAlert = true // Show alert if group name is empty
            }
        }
    }
}
