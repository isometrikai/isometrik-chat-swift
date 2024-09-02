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
//    @EnvironmentObject var vm: OnboardingViewModel
    @State public var showSheet = false
    @State public var image : [UIImage] = []
    @EnvironmentObject public var realmManager : RealmManager
    @Environment(\.dismiss) public var dismiss
//    public var ismChatSDK: ISMChatSdk?
    @State public var isSwitchOn : Bool = true
    @State public var showLastSeen : Bool = true
    @State public var userName : String = ""
    @State public var email : String = ""
    @State public var about : String = ""
    @State public var userProfileImageUrl : String = ""
    @State public var userNameAlert : Bool = false
    @State public var emailAlert : Bool = false
    @State public var selectedMedia : [URL] = []
    @State public var themeFonts = ISMChatSdkUI.getInstance().getAppAppearance().appearance.fonts
    @State public var themeColor = ISMChatSdkUI.getInstance().getAppAppearance().appearance.colorPalette
    @State public var themeImage = ISMChatSdkUI.getInstance().getAppAppearance().appearance.images
    @State public var userData = ISMChatSdk.getInstance().getChatClient().getConfigurations().userConfig
    
    //MARK: - BODY
    public var body: some View {
        NavigationView{
            ZStack {
                themeColor.messageListBackgroundColor.edgesIgnoringSafeArea(.all)
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
                                            .foregroundColor(themeColor.userProfileEditText)
                                            .font(themeFonts.userProfileeditText)
                                    }
                                }
                                Text("Enter your name and add an optional profile picture")
                                    .foregroundColor(themeColor.userProfileDescription)
                                    .font(themeFonts.userProfileDescription)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                Spacer()
                                
                            }
                            Divider()
                                .background(themeColor.userProfileSeparator)
                            
                            TextField("Enter name", text: $userName)
                                .font(themeFonts.userProfilefields)
                                .foregroundColor(themeColor.userProfileFields)
                            
                        }
                        
                        Section(header: Text("Email")) {
                            TextField("Enter email", text: $email)
                                .font(themeFonts.userProfilefields)
                                .foregroundColor(themeColor.userProfileFields)
                            
                        }
                        
                        Section(header: Text("About")) {
                            TextField("", text: $about)
                                .font(themeFonts.userProfilefields)
                                .foregroundColor(themeColor.userProfileFields)
                        }
                        
                        Section() {
                            HStack(spacing: 15){
                                themeImage.NotificationsIcon
                                    .resizable()
                                    .frame(width: 29, height: 29)
                                Text("Notifications")
                                    .font(themeFonts.userProfilefields)
                                    .foregroundColor(themeColor.userProfileFields)
                                Spacer()
                                Toggle("", isOn: $isSwitchOn)
                            }
                            HStack(spacing: 15){
                                themeImage.lastSeenIcon
                                    .resizable()
                                    .frame(width: 29, height: 29)
                                Text("Last Seen")
                                    .font(themeFonts.userProfilefields)
                                    .foregroundColor(themeColor.userProfileFields)
                                Spacer()
                                Toggle("", isOn: $showLastSeen)
                            }
                            Button {
                                Task{
                                    
//                                    vm.signOut { _ in
//                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
//                                            ismChatSDK?.onTerminate()
//                                        })
//                                    }
                                }
                            } label: {
                                HStack(spacing: 15){
                                    themeImage.LogoutIcon
                                        .resizable()
                                        .frame(width: 29, height: 29)
                                    Text("Logout")
                                        .font(themeFonts.userProfilefields)
                                        .foregroundColor(themeColor.userProfileFields)
                                    Spacer()
                                }
                            }
                        }
                    }
                    .listStyle(DefaultListStyle())
                    .onAppear(perform: {
                        self.userName = userData.userName
                        self.email = userData.userEmail
                        self.userProfileImageUrl = userData.userProfileImage
                        self.isSwitchOn = userData.allowNotification
                        if userData.userBio != ""{
                            self.about = userData.userBio
                        }else{
//                            self.about = "Hey there! I m using Wetalk."
                        }
                        self.showLastSeen = userData.showLastSeen
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
                                .font(themeFonts.navigationBarTitle)
                                .foregroundColor(themeColor.navigationBarTitle)
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
                userData.userProfileImage = user.userProfileImageUrl ?? ""
                userData.userName =  user.userName ?? ""
                userData.userEmail =  user.userIdentifier ?? ""
                userData.userBio =  user.metaData?.about ?? ""
                userData.allowNotification = user.notification ?? true
                userData.showLastSeen = user.metaData?.showlastSeen ?? true
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
                        .font(themeFonts.userProfileDoneButton)
                        .foregroundColor(themeColor.userProfileDoneButton)
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

