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
    
    @Binding var dissmiss: Bool // Binding to dismiss the view
    @Binding var selectedContact : [ISMChatPhoneContact] // Binding to hold selected contacts
    @Binding var shareContact : Bool // Binding to indicate if sharing is in progress
    
    @State private var query = "" // State variable for search query
    @ObservedObject var viewModel = ConversationViewModel() // ViewModel for managing conversation data
    @State private var contacts : [ISMChatContacts] = [] // State variable to hold fetched contacts
    @State var contactSectionDictionary : Dictionary<String , [ISMChatContacts]> = [:] // Dictionary to organize contacts by section
    
    @State private var createconversation : ISMChatCreateConversationResponse? // State variable for conversation response
    @State var selection: Bool = false // State variable for selection state
    @State private var conversationId : String = "" // State variable for conversation ID
    
    @State var contactSelected : [ISMChatContacts] = [] // State variable for currently selected contacts
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance // Appearance settings
    @State private var isLoading = true // Add loading state
    
    //MARK: - BODY
    var body: some View {
        ZStack{
            NavigationStack {
                VStack {
                    if isLoading {
                        // Show loader while loading
                        VStack {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .scaleEffect(1.5)
                            Text("Loading contacts...")
                                .font(appearance.fonts.chatListUserMessage)
                                .foregroundColor(appearance.colorPalette.chatListUserMessage)
                                .padding(.top, 10)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollViewReader { proxy in
                            List {
                                // Display header if any contacts are selected
                                if contactSelected.count > 0 {
                                    HeaderView()
                                }
                                
                                // Iterate through sorted keys of the contact section dictionary
                                ForEach(contactSectionDictionary.keys.sorted(), id: \.self) { key in
                                    // Filter contacts based on the search query
                                    if let contacts = contactSectionDictionary[key]?.filter({ contact in
                                        self.query.isEmpty ? true : "\(contact.contact)".lowercased().contains(self.query.lowercased())
                                    }), !contacts.isEmpty {
                                        Section(header: Text("\(key)").font(.system(size: 14))) {
                                            // Display each contact in the section
                                            ForEach(contacts) { value in
                                                ZStack {
                                                    HStack(spacing: 10) {
                                                        // Display contact image or fallback avatar
                                                        if value.contact.imageDataAvailable,
                                                           let data = value.contact.imageData,
                                                           let image = UIImage(data: data) {
                                                            Image(uiImage: image)
                                                                .resizable()
                                                                .frame(width: 37, height: 37)
                                                                .aspectRatio(contentMode: .fill)
                                                                .clipShape(Circle())
                                                        } else {
                                                            UserAvatarView(avatar: "", showOnlineIndicator: false, userName: key)
                                                                .frame(width: 37, height: 37)
                                                                .clipShape(Circle())
                                                        }
                                                        
                                                        // Display contact name and phone number
                                                        VStack(alignment: .leading, spacing: 5) {
                                                            Text("\(value.contact.givenName) \(value.contact.familyName)")
                                                                .font(appearance.fonts.chatListUserName)
                                                                .foregroundColor(appearance.colorPalette.chatListUserName)
                                                                .lineLimit(nil)
                                                            
                                                            if let phoneNumber = value.contact.phoneNumbers.first?.value {
                                                                Text(phoneNumber.stringValue)
                                                                    .font(appearance.fonts.chatListUserMessage)
                                                                    .foregroundColor(appearance.colorPalette.chatListUserMessage)
                                                            }
                                                        }
                                                        
                                                        Spacer()
                                                        
                                                        // Selection indicator
                                                        if contactSelected.contains(where: { $0.id == value.id }) {
                                                            appearance.images.selected
                                                                .resizable()
                                                                .frame(width: 20, height: 20)
                                                        } else {
                                                            appearance.images.deselected
                                                                .resizable()
                                                                .frame(width: 20, height: 20)
                                                        }
                                                    }
                                                    
                                                    // Button to select/deselect contact
                                                    Button {
                                                        contactSelection(value: value)
                                                    } label: {
                                                        // Empty label for button tap area
                                                        EmptyView()
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            .listStyle(DefaultListStyle())
                        }
                    }
                }//:VStack
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
                .navigationBarItems(leading: navBarLeadingBtn, trailing: navBarTrailingBtn)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        VStack {
                            Text("Share Contacts")
                                .font(appearance.fonts.navigationBarTitle)
                                .foregroundColor(appearance.colorPalette.navigationBarTitle)
                        }
                    }
                }
            }.navigationViewStyle(StackNavigationViewStyle())
                .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always))
                .onAppear {
                    requestContactAccess() // Request access to contacts when the view appears
                }
        }
    }
    
    //MARK: - CONFIGURE
    func HeaderView() -> some View{
        // Header view to display selected contacts
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
                                        appearance.images.removeUserFromSelectedFromList
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                    }
                                    
                                    Text(user.contact.givenName)
                                        .font(appearance.fonts.chatListUserMessage)
                                        .foregroundColor(appearance.colorPalette.chatListUserMessage)
                                        .lineLimit(2)
                                }.onTapGesture {
                                    // Remove contact from selection on tap
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
                } .onChange(of: contactSelected.count, { _, _ in
                    withAnimation {  // Add animation for scroll to top
                        reader.scrollTo(contactSelected.last?.id, anchor: .center) // Scroll to the last selected contact
                    }
                })
            }
        }.padding(.vertical,5)
    }
    
    var navBarTrailingBtn: some View {
        // Button to finalize sharing of selected contacts
        VStack{
            Button(action: {
                self.share() // Call share function
                self.shareContact = true // Indicate sharing is in progress
                self.dissmiss = false // Dismiss the view
            }) {
                Text("Done")
                    .font(appearance.fonts.messageListMessageText)
                    .foregroundColor(contactSelected.count == 0 ? Color.gray : appearance.colorPalette.userProfileEditText)
            }.disabled(contactSelected.count == 0) // Disable button if no contacts are selected
        }
    }
    
    var navBarLeadingBtn: some View {
        // Button to cancel the sharing process
        Button(action: { self.dissmiss = false }) {
            Text("Cancel")
                .font(appearance.fonts.messageListMessageText)
                .foregroundColor(appearance.colorPalette.userProfileEditText)
        }
    }
    
    public func contactSelection(value : ISMChatContacts){
        // Function to handle contact selection and deselection
        if contactSelected.contains(where: { contact in
            contact.id == value.id
        }){
            contactSelected.removeAll(where: { $0.id == value.id }) // Remove contact if already selected
            query = "" // Dismiss keyboard
        }else{
            contactSelected.append(value) // Add contact to selection
            query = "" // Dismiss keyboard
        }
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil) // Dismiss keyboard
    }
    
    public func dataToURLString(_ data: Data) -> String? {
        // Convert data to a URL-encoded string
        let urlString = String(data: data, encoding: .utf8)
        return urlString?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }
    
    public func share(){
        // Function to share selected contacts
        for x in contactSelected{
            guard let number = x.contact.phoneNumbers.first?.value.stringValue else {return} // Get phone number
            let phone = ISMChatPhone(number: "\(number)") // Create phone object
            let imageUrl = "https://res.cloudinary.com/dxkoc9aao/image/upload/v1616075844/kesvhgzyiwchzge7qlsz_yfrh9x.jpg" // Placeholder image URL
            let contactInfo : ISMChatPhoneContact = ISMChatPhoneContact(id: x.id, displayName: "\(x.contact.givenName) \(x.contact.familyName)", phones: [phone], imageUrl: imageUrl, imageData: x.contact.imageData ?? Data()) // Create contact info object
            selectedContact.append(contactInfo) // Append to selected contacts
        }
    }
    
    public func sectionIndexTitles(proxy: ScrollViewProxy) -> some View {
        // Function to display section index titles for quick navigation
        SectionIndexTitles(proxy: proxy, titles: contactSectionDictionary.keys.sorted())
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding()
    }
    
    public func requestContactAccess() {
        // Request access to the user's contacts
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { (granted, error) in
            if granted {
                fetchContacts() // Fetch contacts if access is granted
            } else {
                // Handle not granted access
            }
        }
    }
    
    public func fetchContacts() {
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            let store = CNContactStore()
            let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactImageDataAvailableKey, CNContactImageDataKey]
            
            do {
                // Fetch contacts in batches
                let batchSize = 100
                var currentBatch: [ISMChatContacts] = []
                
                try store.enumerateContacts(with: CNContactFetchRequest(keysToFetch: keysToFetch as [CNKeyDescriptor])) { (contact, stop) in
                    // Only process contacts that have valid phone numbers
                    let validPhoneNumbers = contact.phoneNumbers.filter { phoneNumber in
                        let number = phoneNumber.value.stringValue
                        // Remove all non-digit characters
                        let digitsOnly = number.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
                        // Check if the number has a reasonable length (between 7 and 15 digits)
                        return digitsOnly.count >= 7 && digitsOnly.count <= 15
                    }
                    
                    guard !validPhoneNumbers.isEmpty else { return }
                    
                    // Create a new contact with only valid phone numbers
                    let validContact = CNMutableContact()
                    validContact.givenName = contact.givenName
                    validContact.familyName = contact.familyName
                    validContact.phoneNumbers = validPhoneNumbers
                    validContact.imageData = contact.imageData
                    
                    currentBatch.append(ISMChatContacts(id: UUID(), contact: validContact))
                    
                    // When batch is full, update UI and clear batch
                    if currentBatch.count >= batchSize {
                        let batchToAdd = currentBatch
                        DispatchQueue.main.async {
                            self.contacts.append(contentsOf: batchToAdd)
                            self.contactSectionDictionary = self.viewModel.getContactDictionary(data: self.contacts)
                        }
                        currentBatch.removeAll(keepingCapacity: true)
                    }
                }
                
                // Process any remaining contacts
                if !currentBatch.isEmpty {
                    let finalBatch = currentBatch
                    DispatchQueue.main.async {
                        self.contacts.append(contentsOf: finalBatch)
                        self.contactSectionDictionary = self.viewModel.getContactDictionary(data: self.contacts)
                        self.isLoading = false // Hide loader after all contacts are loaded
                    }
                } else {
                    DispatchQueue.main.async {
                        self.isLoading = false // Hide loader if no contacts were loaded
                    }
                }
            } catch {
                print("Error fetching contacts: \(error)")
                DispatchQueue.main.async {
                    self.isLoading = false // Hide loader in case of error
                }
            }
        }
    }
}

