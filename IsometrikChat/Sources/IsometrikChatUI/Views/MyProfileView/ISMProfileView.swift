//
//  ISM_Profile.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 09/03/23.
//

import SwiftUI
import ISMSwiftCall
import IsometrikChat

public struct ISMProfileView: View {
    
    //MARK:  - PROPERTIES
    @ObservedObject var viewModel = ConversationViewModel(ismChatSDK: ISMChatSdk.getInstance())
//    @EnvironmentObject var vm: OnboardingViewModel
    @State private var showSheet = false
    @State private var image : [UIImage] = []
    @EnvironmentObject var realmManager : RealmManager
    @Environment(\.dismiss) var dismiss
    public var ismChatSDK: ISMChatSdk?
    @State var isSwitchOn : Bool = true
    @State var showLastSeen : Bool = true
    @State private var userName : String = ""
    @State private var email : String = ""
    @State private var about : String = ""
    @State private var userProfileImageUrl : String = ""
    @State private var userNameAlert : Bool = false
    @State private var emailAlert : Bool = false
    @State private var selectedMedia : [URL] = []
    @State var themeFonts = ISMChatSdkUI.getInstance().getAppAppearance().appearance.fonts
    @State var themeColor = ISMChatSdkUI.getInstance().getAppAppearance().appearance.colorPalette
    @State var themeImage = ISMChatSdkUI.getInstance().getAppAppearance().appearance.images
    @State var userSession = ISMChatSdk.getInstance().getUserSession()
    
    //MARK: - BODY
    public var body: some View {
        NavigationView{
            ZStack {
                themeColor.messageList_BackgroundColor.edgesIgnoringSafeArea(.all)
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
                                            .foregroundColor(themeColor.userProfile_editText)
                                            .font(themeFonts.userProfile_editText)
                                    }
                                }
                                Text("Enter your name and add an optional profile picture")
                                    .foregroundColor(themeColor.userProfile_Description)
                                    .font(themeFonts.userProfile_Description)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                Spacer()
                                
                            }
                            Divider()
                                .background(themeColor.userProfile_Separator)
                            
                            TextField("Enter name", text: $userName)
                                .font(themeFonts.userProfile_fields)
                                .foregroundColor(themeColor.userProfile_fields)
                            
                        }
                        
                        Section(header: Text("Email")) {
                            TextField("Enter email", text: $email)
                                .font(themeFonts.userProfile_fields)
                                .foregroundColor(themeColor.userProfile_fields)
                            
                        }
                        
                        Section(header: Text("About")) {
                            TextField("", text: $about)
                                .font(themeFonts.userProfile_fields)
                                .foregroundColor(themeColor.userProfile_fields)
                        }
                        
                        Section() {
                            HStack(spacing: 15){
                                themeImage.NotificationsIcon
                                    .resizable()
                                    .frame(width: 29, height: 29)
                                Text("Notifications")
                                    .font(themeFonts.userProfile_fields)
                                    .foregroundColor(themeColor.userProfile_fields)
                                Spacer()
                                Toggle("", isOn: $isSwitchOn)
                            }
                            HStack(spacing: 15){
                                themeImage.lastSeenIcon
                                    .resizable()
                                    .frame(width: 29, height: 29)
                                Text("Last Seen")
                                    .font(themeFonts.userProfile_fields)
                                    .foregroundColor(themeColor.userProfile_fields)
                                Spacer()
                                Toggle("", isOn: $showLastSeen)
                            }
                            Button {
                                ismChatSDK?.onTerminate()
                                let ismcallsdk = IsometrikCall()
                                ismcallsdk.clearSession()
                                ISMCallManager.shared.invalidatePushKitAPNSDeviceToken(type: .voIP)
                                Task{
//                                    vm.signOut { _ in
//                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
//                                            realmManager.deleteAllData()
//                                        })
//                                    }
                                }
                            } label: {
                                HStack(spacing: 15){
                                    themeImage.LogoutIcon
                                        .resizable()
                                        .frame(width: 29, height: 29)
                                    Text("Logout")
                                        .font(themeFonts.userProfile_fields)
                                        .foregroundColor(themeColor.userProfile_fields)
                                    Spacer()
                                }
                            }
                        }
                    }
                    .listStyle(DefaultListStyle())
                    .onAppear(perform: {
                        self.userName = userSession.getUserName()
                        self.email = userSession.getEmailId()
                        self.userProfileImageUrl = userSession.getUserProfilePicture()
                        self.isSwitchOn = userSession.getNotificationStatus()
                        if userSession.getUserBio() != ""{
                            self.about = userSession.getUserBio()
                        }else{
                            self.about = "Hey there! I m using Wetalk."
                        }
                        self.showLastSeen = userSession.getLastSeenStatus()
                    })
                    .sheet(isPresented: $showSheet){
                        ISMMediaPickerView(selectedMedia: $selectedMedia, selectedProfilePicture: $image, isProfile: true)
                    }
                    .onChange(of: isSwitchOn) { _ in
                        updateNotification()
                    }
                    .onChange(of: showLastSeen) { _ in
                        updateLastSeen()
                    }
                }
                
                if userNameAlert == true{
                    Text("User name can't be empty")
                        .font(themeFonts.alertText)
                        .padding()
                        .background(themeColor.alertBackground)
                        .foregroundColor(themeColor.alertText)
                        .cornerRadius(5)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                userNameAlert = false
                            }
                        }
                }
                if emailAlert == true{
                    Text("Email can't be empty")
                        .font(themeFonts.alertText)
                        .padding()
                        .background(themeColor.alertBackground)
                        .foregroundColor(themeColor.alertText)
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
                                .font(themeFonts.navigationBar_Title)
                                .foregroundColor(themeColor.navigationBar_Title)
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
                userSession.setUserProfilePicture(url: user.userProfileImageUrl ?? "")
                userSession.setUserName(userName: user.userName ?? "")
                userSession.setUserEmailId(email: user.userIdentifier ?? "")
                userSession.setUserBio(bio: user.metaData?.about ?? "")
                userSession.setnotification(on: user.notification ?? true)
                userSession.setLastSeen(showLastSeen: user.metaData?.showlastSeen ?? true)
                completion()
            }
        }
    }
    var navBarLeadingBtn : some View{
        Button {
            dismiss()
        } label: {
            themeImage.CloseSheet
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
                        .font(themeFonts.userProfile_DoneButton)
                        .foregroundColor(themeColor.userProfile_DoneButton)
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

