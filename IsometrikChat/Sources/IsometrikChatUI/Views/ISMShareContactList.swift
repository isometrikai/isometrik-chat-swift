//
//  ISMShareContactList.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 19/10/23.
//

import SwiftUI
import Contacts
import IsometrikChat

struct ISMShareContactList: View {
    
    //MARK: - PROPERTIES
    
    @Binding var dissmiss: Bool
    @Binding var selectedContact : [ISMChat_PhoneContact]
    @Binding var shareContact : Bool
    
    
    @State private var query = ""
    @ObservedObject var viewModel = ConversationViewModel(ismChatSDK: ISMChatSdk.getInstance())
    @State private var contacts : [ISMChat_Contacts] = []
    @State var contactSectionDictionary : Dictionary<String , [ISMChat_Contacts]> = [:]
    
    
    @State private var createconversation : ISMChat_CreateConversationResponse?
    @State var selection: Bool = false
    @State private var conversationId : String = ""
    
    
    @State var contactSelected : [ISMChat_Contacts] = []
    @State var themeFonts = ISMChatSdk.getInstance().getAppAppearance().appearance.fonts
    @State var themeColor = ISMChatSdk.getInstance().getAppAppearance().appearance.colorPalette
    @State var themeImage = ISMChatSdk.getInstance().getAppAppearance().appearance.images
    
    //MARK: - BODY
    var body: some View {
        ZStack{
            NavigationView {
                VStack {
                    ScrollViewReader { proxy in
                        List {
                            if contactSelected.count > 0 {
                                HeaderView()
                            }
                            
                            ForEach(contactSectionDictionary.keys.sorted(), id:\.self) { key in
                                if let contacts = contactSectionDictionary[key]?.filter({ (contact) -> Bool in
                                    self.query.isEmpty ? true :
                                    "\(contact)".lowercased().contains(self.query.lowercased())
                                }), !contacts.isEmpty {
                                    Section(header: Text("\(key)").font(Font.regular(size: 14))) {
                                        ForEach(contacts) { value in
                                            ZStack {
                                                HStack(spacing : 10) {
                                                    if value.contact.imageDataAvailable{
                                                        if let data = value.contact.imageData, let image = UIImage(data: data) {
                                                            Image(uiImage: image)
                                                                .resizable()
                                                                .frame(width: 29, height: 29)
                                                                .aspectRatio(contentMode: .fill)
                                                                .clipShape(Circle())
                                                        } else {
                                                            UserAvatarView(avatar: "", showOnlineIndicator: false, userName: key)
                                                                .frame(width: 29, height: 29)
                                                                .clipShape(Circle())
                                                        }
                                                    }else{
                                                        UserAvatarView(avatar: "", showOnlineIndicator: false, userName: key)
                                                            .frame(width: 29, height: 29)
                                                            .clipShape(Circle())
                                                    }
                                                    
                                                    VStack(alignment: .leading, spacing: 5) {
                                                        Text("\(value.contact.givenName) \(value.contact.familyName)")
                                                            .font(themeFonts.messageList_MessageText)
                                                            .foregroundColor(themeColor.messageList_MessageText)
                                                            .lineLimit(nil)
                                                        
                                                        if let phoneNumber = value.contact.phoneNumbers.first?.value {
                                                            Text(phoneNumber.stringValue)
                                                                .font(themeFonts.chatList_UserMessage)
                                                                .foregroundColor(themeColor.chatList_UserMessage)
                                                        }
                                                    }
                                                    
                                                    Spacer()
                                                    
                                                    if contactSelected.contains(where: { user in
                                                        user.id == value.id
                                                    }) {
                                                        themeImage.selected
                                                            .resizable()
                                                            .frame(width: 20, height: 20)
                                                    }else{
                                                        themeImage.deselected
                                                            .resizable()
                                                            .frame(width: 20, height: 20)
                                                    }
                                                }
                                                
                                                Button {
                                                    contactSelection(value: value)
                                                } label: {}
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .listStyle(DefaultListStyle())
                    }
                }//:VStack
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
                .navigationBarItems(leading: navBarLeadingBtn, trailing: navBarTrailingBtn)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        VStack {
                            Text("Share Contacts")
                                .font(themeFonts.navigationBar_Title)
                                .foregroundColor(themeColor.navigationBar_Title)
                        }
                    }
                }
            }.navigationViewStyle(StackNavigationViewStyle())
                .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always))
                .onAppear {
                    requestContactAccess()
                    
                }
        }
    }
    
    //MARK: - CONFIGURE
    func HeaderView() -> some View{
        
        HStack(alignment: .top){
            ScrollViewReader { reader in
                ScrollView(.horizontal,showsIndicators: false) {
                    LazyHStack(alignment: .top){
                        ForEach(contactSelected) { user in
                            ZStack{
                                VStack(spacing: 3){
                                    ZStack(alignment: .topTrailing) {
                                        UserAvatarView(avatar: "", showOnlineIndicator: false, userName: user.contact.givenName)
                                            .frame(width: 48, height: 48)
                                            .clipShape(Circle())
                                        themeImage.removeUserFromSelectedFromList
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                    }
                                    
                                    Text(user.contact.givenName)
                                        .font(themeFonts.chatList_UserMessage)
                                        .foregroundColor(themeColor.chatList_UserMessage)
                                        .lineLimit(2)
                                }.onTapGesture {
                                    if contactSelected.contains(where: { user1 in
                                        user1.id == user.id
                                    }){
                                        contactSelected.removeAll(where: { $0.id == user.id })
                                    }
                                }
                            }.frame(width: 60)
                                .id(user.id)
                        }
                    }
                } .onChange(of: contactSelected.count) { _ in
                    withAnimation {  // add animation for scroll to top
                        reader.scrollTo(contactSelected.last?.id, anchor: .center) // scroll
                    }
                }
            }
        }.padding(.vertical,5)
    }
    
    var navBarTrailingBtn: some View {
        VStack{
            Button(action: {
                self.share()
                self.shareContact = true
                self.dissmiss = false
            }) {
                Text("Done")
                    .font(themeFonts.messageList_MessageText)
                    .foregroundColor(contactSelected.count == 0 ? Color.gray : themeColor.userProfile_editText)
            }.disabled(contactSelected.count == 0)
        }
    }
    
    var navBarLeadingBtn: some View {
        Button(action: { self.dissmiss = false }) {
            Text("Cancel")
                .font(themeFonts.messageList_MessageText)
                .foregroundColor(themeColor.userProfile_editText)
        }
    }
    
    public func contactSelection(value : ISMChat_Contacts){
        if contactSelected.contains(where: { contact in
            contact.id == value.id
        }){
            contactSelected.removeAll(where: { $0.id == value.id })
            //when selected or removed dismiss keyboard
            query = ""
        }else{
            contactSelected.append(value)
            //when selected or removed dismiss keyboard
            query = ""
        }
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
    }
    
    public func dataToURLString(_ data: Data) -> String? {
        let urlString = String(data: data, encoding: .utf8)
        return urlString?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }
    
    public func share(){
        for x in contactSelected{
            guard let number = x.contact.phoneNumbers.first?.value.stringValue else {return}
            let phone = ISMChat_Phone(number: "\(number)")
            let imageUrl = "https://res.cloudinary.com/dxkoc9aao/image/upload/v1616075844/kesvhgzyiwchzge7qlsz_yfrh9x.jpg"
            let contactInfo : ISMChat_PhoneContact = ISMChat_PhoneContact(id: x.id, displayName: "\(x.contact.givenName) \(x.contact.familyName)", phones: [phone], imageUrl: imageUrl, imageData: x.contact.imageData ?? Data())
            selectedContact.append(contactInfo)
        }
    }
    
    public func sectionIndexTitles(proxy: ScrollViewProxy) -> some View {
        SectionIndexTitles(proxy: proxy, titles: contactSectionDictionary.keys.sorted())
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding()
    }
    
    public func requestContactAccess() {
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { (granted, error) in
            if granted {
                fetchContacts()
            } else {
                // Handle not granted access
            }
        }
    }
    
    public func fetchContacts() {
        // Create a background queue
        DispatchQueue.global(qos: .background).async {
            let store = CNContactStore()
            let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactImageDataAvailableKey, CNContactImageDataKey]
            let request = CNContactFetchRequest(keysToFetch: keysToFetch as [CNKeyDescriptor])
            
            do {
                try store.enumerateContacts(with: request) { (contact, _) in
//                    contacts.append(ISMChat_Contacts(id: UUID(), contact: contact))
                }
            } catch {
                // Handle the error
                print("Error fetching contacts: \(error)")
            }
            
            // Once the contacts are fetched, update the UI on the main thread
            DispatchQueue.main.async {
                if contacts.count > 0 {
                    contactSectionDictionary = viewModel.getContactDictionary(data: contacts)
                }
            }
        }
    }
}

