//
//  ISMSearchParticipants.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 27/07/23.
//

import SwiftUI
import IsometrikChat

struct ISMSearchParticipants: View {
    
    //MARK: - PROPERTIES
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @ObservedObject var viewModel = ChatsViewModel(ismChatSDK: ISMChatSdk.getInstance())
    @ObservedObject var conversationViewModel = ConversationViewModel(ismChatSDK: ISMChatSdk.getInstance())
    @State var selectedMember : ISMChat_GroupMember = ISMChat_GroupMember()
    @State private var query = ""
    @State var showOptions : Bool = false
    @State var originalMembers : ISMGroupMember?
    @State var members : ISMGroupMember?
    var conversationID : String?
    @State private var isEditing  : Bool = false
    @State var themeFonts = ISMChatSdkUI.getInstance().getAppAppearance().appearance.fonts
    @State var themeColor = ISMChatSdkUI.getInstance().getAppAppearance().appearance.colorPalette
    @State var themeImage = ISMChatSdkUI.getInstance().getAppAppearance().appearance.images
    
    //MARK: - BODY
    var body: some View {
        VStack{
            List{
                Section {
                    if let members = members{
                        ForEach(members.conversationMembers ?? [], id: \.self) { member in
                            ISMGroupMemberSubView(member: member, hideDisclosure: true, selectedMember: $selectedMember)
                        }
                    }
                } header: {
                    if let count = members?.membersCount{
                        Text("\(count) Members")
                            .font(themeFonts.chatList_UserMessage)
                            .foregroundColor(themeColor.chatList_UserMessage)
                    }
                } footer: {
                    Text("")
                }
                
            }.listRowSeparatorTint(themeColor.chatList_separatorColor)
                .background(themeColor.chatList_Background)
                .scrollContentBackground(.hidden)
                .searchable(text:  $query, placement: .navigationBarDrawer(displayMode: .always)) {}
                .onChange(of: query, perform: { newValue in
                    if query == ""{
                        isEditing = false
                        members?.conversationMembers =  originalMembers?.conversationMembers
                    }else{
                        isEditing = true
                        members?.conversationMembers =  members?.conversationMembers?.filter({ $0.userName?.range(of: query, options: .caseInsensitive) != nil })
                    }
                })
                .onChange(of: isEditing) { newValue in
                    if isEditing == false && query == ""{
                        members?.conversationMembers =  originalMembers?.conversationMembers
                    }
                }
            
        }
        .onAppear{
            getMembers()
        }
        .onChange(of: selectedMember, perform: { newValue in
            showOptions = true
        })
        .confirmationDialog("", isPresented: $showOptions) {
            Button {
                //navigate to detailed contact Info
            } label: {
                Text("Info")
            }
            Button {
                makeGroupAdmin()
            } label: {
                Text(selectedMember.isAdmin == false ? "Make Group Admin" : "Dismiss as Admin")
            }
            Button {
                removefromGroup()
            } label: {
                Text("Remove from Group")
            }
            Button("Cancel", role: .cancel, action: {})
        } message: {
            Text(selectedMember.userName ?? "")
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text("Search Participants")
                        .font(themeFonts.navigationBar_Title)
                        .foregroundColor(themeColor.navigationBar_Title)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: navBarLeadingBtn)
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
    
    func getMembers(){
        viewModel.getGroupMembers(conversationId: self.conversationID ?? "") { data in
            members = data
            originalMembers = data
        }
    }
    
    func makeGroupAdmin(){
        if selectedMember.isAdmin == false{
            viewModel.addGroupAdmin(memberId: selectedMember.userId ?? "", conversationId: conversationID ?? "") { data in
                getMembers()
            }
        }else{
            viewModel.removeGroupAdmin(memberId: selectedMember.userId ?? "", conversationId: conversationID ?? "") { data in
                getMembers()
            }
        }
    }
    
    func removefromGroup(){
        viewModel.removeUserFromGroup(members: selectedMember.userId ?? "", conversationId: conversationID ?? "") { _ in
            getMembers()
        }
    }
}

