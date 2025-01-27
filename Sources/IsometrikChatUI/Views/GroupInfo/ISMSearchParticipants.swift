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
    
    /// View model for managing chat-related operations
    @ObservedObject var viewModel = ChatsViewModel()
    
    /// View model for conversation-specific operations
    @ObservedObject var conversationViewModel = ConversationViewModel()
    
    /// Currently selected member in the list
    @State var selectedMember : ISMChatGroupMember = ISMChatGroupMember()
    
    /// Search query string
    @State private var query = ""
    
    /// Controls visibility of member options dialog
    @State var showOptions : Bool = false
    
    /// Stores the original list of members before any filtering
    @State var originalMembers : ISMGroupMember?
    
    /// Current filtered list of members
    @State var members : ISMGroupMember?
    
    /// ID of the current conversation/group
    var conversationID : String?
    
    /// Tracks if user is currently editing the search field
    @State private var isEditing : Bool = false
    
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    
    //MARK: - BODY
    var body: some View {
        VStack{
            List{
                if let member = members,(member.conversationMembers?.count ?? 0) > 0{
                    Section {
                        ForEach(member.conversationMembers ?? [], id: \.self) { mem in
                            VStack{
                                ISMGroupMemberSubView(member: mem, hideDisclosure: true, selectedMember: $selectedMember)
                                Divider()
                                    .background(Color.border) // Customize color
                                    .frame(height: 0.5)
                            }
                        }
                    }.listRowSeparator(.hidden)
                }else{
                    VStack {
                        Spacer()
                        appearance.placeholders.groupInfo_groupMembers
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .listRowSeparator(.hidden)
                }
                
            }
            
            .listRowSeparatorTint(appearance.colorPalette.chatListSeparatorColor)
                .listStyle(.plain)
                .background(appearance.colorPalette.chatListBackground)
                .scrollContentBackground(.hidden)
                .searchable(text:  $query, placement: .navigationBarDrawer(displayMode: .always)) {}
                .onChange(of: query, { _, _ in
                    if query == ""{
                        isEditing = false
                        members?.conversationMembers =  originalMembers?.conversationMembers
                    }else{
                        isEditing = true
                        members?.conversationMembers =  members?.conversationMembers?.filter({ $0.userName?.range(of: query, options: .caseInsensitive) != nil })
                    }
                })
                .onChange(of: isEditing, { _, _ in
                    if isEditing == false && query == ""{
                        members?.conversationMembers =  originalMembers?.conversationMembers
                    }
                })
            
        }
        .onAppear{
            getMembers()
        }
        .onChange(of: selectedMember, { _, _ in
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
                    Text("Search members")
                        .font(appearance.fonts.navigationBarTitle)
                        .foregroundColor(appearance.colorPalette.navigationBarTitle)
                    if let count = members?.membersCount{
                        Text("\(count) people")
                            .font(appearance.fonts.messageListHeaderDescription)
                            .foregroundColor(appearance.colorPalette.messageListHeaderDescription)
                    }
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
            appearance.images.backButton
                .resizable()
                .frame(width: appearance.imagesSize.backButton.width, height: appearance.imagesSize.backButton.height)
        }
    }
    
    // MARK: - Helper Methods
    
    /// Fetches group members from the server
    func getMembers(){
        viewModel.getGroupMembers(conversationId: self.conversationID ?? "") { data in
            members = data
            originalMembers = data
        }
    }
    
    /// Toggles admin status for the selected member
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
    
    /// Removes the selected member from the group
    func removefromGroup(){
        viewModel.removeUserFromGroup(members: selectedMember.userId ?? "", conversationId: conversationID ?? "") { _ in
            getMembers()
        }
    }
}

