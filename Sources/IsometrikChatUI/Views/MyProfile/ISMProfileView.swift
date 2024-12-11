//
//  ISMProfile.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 09/03/23.
//

import SwiftUI
import ISMSwiftCall
import IsometrikChat

public struct ISMProfileView: View {
    
    //MARK:  - PROPERTIES
    @ObservedObject public var viewModel = ConversationViewModel()
    @State public var showSheet = false
    @State public var image : [UIImage] = []
    @EnvironmentObject public var realmManager : RealmManager
    @Environment(\.dismiss) public var dismiss
    @State public var isSwitchOn : Bool = true
    @State public var showLastSeen : Bool = true
    @State public var userName : String = ""
    @State public var email : String = ""
    @State public var about : String = "Hey there!"
    @State public var userProfileImageUrl : String = ""
    @State public var userNameAlert : Bool = false
    @State public var emailAlert : Bool = false
    @State public var selectedMedia : [URL] = []
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    var userData = ISMChatSdk.getInstance().getChatClient()?.getConfigurations().userConfig
    
    //MARK: - BODY
    public var body: some View {
        NavigationStack{
            ZStack {
                appearance.colorPalette.messageListBackgroundColor.edgesIgnoringSafeArea(.all)
                VStack(alignment: .center){
                    List {
                        VStack{
                            HStack(alignment: .center, spacing: 15){
                                VStack(alignment: .center, spacing: 6){
                                    if let image = image.first{
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 60,height: 60)
                                            .clipShape(
                                                Circle()
                                            )
                                    }else{
                                        UserAvatarView(avatar: userProfileImageUrl , showOnlineIndicator: false,size: CGSize(width: 60, height: 60), userName: userName,font: .regular(size: 20) )
                                    }
                                    Button {
                                        showSheet = true
                                    } label: {
                                        Text("Edit")
                                            .foregroundColor(appearance.colorPalette.userProfileEditText)
                                            .font(appearance.fonts.userProfileeditText)
                                    }
                                }
                                Text("Enter your name and add an optional profile picture")
                                    .foregroundColor(appearance.colorPalette.userProfileDescription)
                                    .font(appearance.fonts.userProfileDescription)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                Spacer()
                                
                            }
                            Divider()
                                .background(appearance.colorPalette.userProfileSeparator)
                            
                            TextField("Enter name", text: $userName)
                                .font(appearance.fonts.userProfilefields)
                                .foregroundColor(appearance.colorPalette.userProfileFields)
                            
                        }
                        
                        Section(header: Text("Email")) {
                            TextField("Enter email", text: $email)
                                .font(appearance.fonts.userProfilefields)
                                .foregroundColor(appearance.colorPalette.userProfileFields)
                            
                        }
                        
                        Section(header: Text("About")) {
                            TextField("", text: $about)
                                .font(appearance.fonts.userProfilefields)
                                .foregroundColor(appearance.colorPalette.userProfileFields)
                        }
                        
                        Section() {
                            HStack(spacing: 15){
                                appearance.images.NotificationsIcon
                                    .resizable()
                                    .frame(width: 29, height: 29)
                                Text("Notifications")
                                    .font(appearance.fonts.userProfilefields)
                                    .foregroundColor(appearance.colorPalette.userProfileFields)
                                Spacer()
                                Toggle("", isOn: $isSwitchOn)
                            }
                            HStack(spacing: 15){
                                appearance.images.lastSeenIcon
                                    .resizable()
                                    .frame(width: 29, height: 29)
                                Text("Last Seen")
                                    .font(appearance.fonts.userProfilefields)
                                    .foregroundColor(appearance.colorPalette.userProfileFields)
                                Spacer()
                                Toggle("", isOn: $showLastSeen)
                            }
                            Button {
                                ISMChatSdk.getInstance().onTerminate(userId: userData?.userId ?? "")
                            } label: {
                                HStack(spacing: 15){
                                    appearance.images.LogoutIcon
                                        .resizable()
                                        .frame(width: 29, height: 29)
                                    Text("Logout")
                                        .font(appearance.fonts.userProfilefields)
                                        .foregroundColor(appearance.colorPalette.userProfileFields)
                                    Spacer()
                                }
                            }
                        }
                    }
                    .listStyle(DefaultListStyle())
                    .onAppear(perform: {
                        self.userName = userData?.userName ?? ""
                        self.email = userData?.userEmail ?? ""
                        self.userProfileImageUrl = userData?.userProfileImage ?? ""
                        self.isSwitchOn = userData?.allowNotification ?? true
                        if userData?.userBio != ""{
                            self.about = userData?.userBio ?? ""
                        }else{
//                            self.about = "Hey there! I m using Wetalk."
                        }
                        self.showLastSeen = userData?.showLastSeen ?? true
                    })
                    .sheet(isPresented: $showSheet){
                        ISMMediaPickerView(selectedMedia: $selectedMedia, selectedProfilePicture: $image, isProfile: true)
                    }
                    .onChange(of: isSwitchOn, { _, _ in
                        updateNotification()
                    })
                    .onChange(of: showLastSeen, { _, _ in
                        updateLastSeen()
                    })
                }
                
                if userNameAlert == true{
                    Text("User name can't be empty")
                        .font(appearance.fonts.alertText)
                        .padding()
                        .background(appearance.colorPalette.alertBackground)
                        .foregroundColor(appearance.colorPalette.alertText)
                        .cornerRadius(5)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                userNameAlert = false
                            }
                        }
                }
                if emailAlert == true{
                    Text("Email can't be empty")
                        .font(appearance.fonts.alertText)
                        .padding()
                        .background(appearance.colorPalette.alertBackground)
                        .foregroundColor(appearance.colorPalette.alertText)
                        .cornerRadius(5)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                emailAlert = false
                            }
                        }
                }
//                if vm.isBusy{
//                    //Custom Progress View
//                    ActivityIndicatorView(isPresented: $vm.isBusy)
//                }
                
            }.navigationBarBackButtonHidden(true)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        VStack {
                            Text("Edit Profile")
                                .font(appearance.fonts.navigationBarTitle)
                                .foregroundColor(appearance.colorPalette.navigationBarTitle)
                        }
                    }
                }
                .navigationBarItems(leading : navBarLeadingBtn,trailing: navBarTrailingBtn)
                .navigationBarTitleDisplayMode(.inline)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
    
    func userData(completion:@escaping()->()){
        viewModel.getUserData { data in
            if let user = data {
                self.viewModel.userData = user
//                userData.userProfileImage = user.userProfileImageUrl ?? ""
//                userData.userName =  user.userName ?? ""
//                userData.userEmail =  user.userIdentifier ?? ""
//                userData.userBio =  user.metaData?.about ?? ""
//                userData.allowNotification = user.notification ?? true
//                userData.showLastSeen = user.metaData?.showlastSeen ?? true
                completion()
            }
        }
    }
    var navBarLeadingBtn : some View{
        Button {
            dismiss()
        } label: {
            appearance.images.CloseSheet
                .resizable()
                .frame(width: 17,height: 17)
        }
    }
    var navBarTrailingBtn : some View{
        VStack{
            if viewModel.userData?.userIdentifier != email || viewModel.userData?.userName != userName || image.first != nil || viewModel.userData?.metaData?.about != about{
                Button {
                    updateProfile()
                } label: {
                    Text("Done")
                        .font(appearance.fonts.userProfileDoneButton)
                        .foregroundColor(appearance.colorPalette.userProfileDoneButton)
                }
            }
        }
    }
    
    func updateNotification(){
        viewModel.updateUserData(notification: isSwitchOn) { _ in
            print("Notication status updated.")
        }
    }
    func updateLastSeen(){
        viewModel.updateUserData(showLastSeen: self.showLastSeen) { _ in
            print("Last Seen status updated.")
        }
    }
    
    func updateProfile(){
        if !userName.isEmpty{
            if !email.isEmpty{
                if let image = image.first{
//                    vm.isBusy = true
                    viewModel.getPredefinedUrlToUpdateProfilePicture(image: image) { value in
                        viewModel.updateUserData(userName: self.userName, userIdentifier: self.email, profileImage: value,about: self.about) { _ in
                            userData {
                                
//                                vm.isBusy = false
                                dismiss()
                            }
                        }
                    }
                }else{
//                    vm.isBusy = true
                    viewModel.updateUserData(userName: self.userName, userIdentifier: self.email, profileImage: nil,about: self.about) { _ in
                        userData {
                            
//                            vm.isBusy = false
                            dismiss()
                        }
                    }
                }
            }else{
                emailAlert = true
            }
        }else{
            userNameAlert = true
        }
    }
}

