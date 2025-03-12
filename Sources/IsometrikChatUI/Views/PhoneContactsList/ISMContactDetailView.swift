//
//  ISMContactDetailView.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 19/10/23.
//

import SwiftUI
import ContactsUI
import UIKit
import Contacts
import IsometrikChat

struct ISMContactDetailView: View {
    
    //MARK: - PROPERTIES
    let data : ISMChatMetaDataDB // Holds the metadata for contacts
    @State private var presentContact : Bool = false // State variable to control the presentation of the contact saving view
    @Environment(\.presentationMode) var presentationMode // Environment variable to manage view presentation
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance // Appearance settings for UI
    
    //MARK: - BODY
    var body: some View {
        VStack{
            HStack{
                // Back button to dismiss the current view
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    appearance.images.backButton
                        .resizable()
                        .frame(width: appearance.imagesSize.backButton.width, height: appearance.imagesSize.backButton.height)
                })
                Spacer()
                
                // Title of the view
                Text("View Contacts")
                    .font(appearance.fonts.navigationBarTitle)
                    .foregroundColor(appearance.colorPalette.navigationBarTitle)
                
                Spacer()
                
                // Placeholder button (currently does nothing)
                Button(action: {  }) {
                    Image("")
                        .resizable()
                        .frame(width: appearance.imagesSize.backButton.width, height: appearance.imagesSize.backButton.height)
                }
                
            }.padding(.horizontal,15)
            
            // List of contacts
            List{
                ForEach(data.contacts ?? [], id: \.self) { index in
                    ContactDetailCell(presentContact: $presentContact, index: index) // Display each contact in a cell
                }.listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .background(Color.white)
            .sheet(isPresented: $presentContact) {
                ContactSavingView() // Present the contact saving view when triggered
            }
        }.navigationBarBackButtonHidden(true) // Hide the default back button
            .navigationBarHidden(true) // Hide the navigation bar
    }
}

struct ContactSavingView: View {
    //MARK: - PROPERTIES
    @State private var contact = CNMutableContact() // Mutable contact object to hold contact details
    @State private var phoneNumbers: [String] = [String()] // Array to hold phone numbers
    @Environment(\.presentationMode) var presentationMode // Environment variable to manage view presentation
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance // Appearance settings for UI
    
    //MARK: - BODY
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    // Text fields for first and last name
                    TextField("First Name", text: $contact.givenName)
                    TextField("Last Name", text: $contact.familyName)
                }
                Section(header: Text("Phone Numbers")) {
                    // Dynamic text fields for phone numbers
                    ForEach(phoneNumbers.indices, id: \.self) { index in
                        TextField("Phone \(index + 1)", text: $phoneNumbers[index])
                    }
                    // Button to add a new phone number field
                    Button(action: {
                        phoneNumbers.append("") // Append a new empty string to the phone numbers array
                    }) {
                        Text("Add Phone Number")
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        // Title for the contact saving view
                        Text("Add Contact")
                            .font(appearance.fonts.navigationBarTitle)
                            .foregroundColor(appearance.colorPalette.navigationBarTitle)
                    }
                }
            }
            .navigationBarItems(leading:
                                    Button(action: {
                presentationMode.wrappedValue.dismiss() // Dismiss the view
            }, label: {
                appearance.images.CloseSheet
                    .resizable()
                    .tint(.black)
                    .foregroundColor(.black)
                    .frame(width: 17,height: 17)
            }),
                                trailing:
                                    Button("Save") {
                saveContact() // Call the saveContact function when the save button is pressed
            }
            )
        }.navigationViewStyle(StackNavigationViewStyle()) // Use stack navigation style
    }
    
    //MARK: - CONFIGURE
    func saveContact() {
        // Clear existing phone numbers
        contact.phoneNumbers.removeAll()
        // Add each phone number to the contact
        for number in phoneNumbers {
            let phoneNumber = CNLabeledValue(label: CNLabelPhoneNumberMain, value: CNPhoneNumber(stringValue: number))
            contact.phoneNumbers.append(phoneNumber)
        }
        
        // Create a save request for the contact
        let saveRequest = CNSaveRequest()
        saveRequest.add(contact, toContainerWithIdentifier: nil) // Add the contact to the save request
        do {
            try CNContactStore().execute(saveRequest) // Execute the save request
            presentationMode.wrappedValue.dismiss() // Dismiss the view after saving
        } catch {
            // Handle the error (consider adding error handling logic)
        }
    }
}

struct ContactDetailCell : View {
    @Binding var presentContact : Bool // Binding to control the presentation of the contact saving view
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance // Appearance settings for UI
    let index : ISMChatContactDB // Contact data for the cell
    var body: some View {
        VStack(spacing:0){
            Spacer()
            HStack(spacing: 10){
                // Display user avatar if available
                if let name = index.contactName{
                    UserAvatarView(avatar: "", showOnlineIndicator: false, userName: name)
                        .frame(width: 44, height: 44)
                        .clipShape(Circle())
                }
                VStack(alignment: .leading, spacing: 5, content: {
                    // Display contact name
                    Text(index.contactName ?? "")
                        .font(appearance.fonts.contactDetailsTitle)
                        .foregroundColor(appearance.colorPalette.messageListHeaderTitle)
                    
                    // Display contact phone number if available
                    if let phones = index.contactIdentifier {
                        Text(phones)
                            .font(appearance.fonts.contactDetailsNumber)
                            .foregroundColor(appearance.colorPalette.chatListUserMessage)
                    }
                })
                Spacer()
                
                // Button to add the contact
                Button {
                    presentContact = true // Trigger the presentation of the contact saving view
                } label: {
                    Text("Add")
                        .font(appearance.fonts.contactDetailsTitle)
                        .foregroundColor(appearance.colorPalette.userProfileEditText)
                    
                }
                .frame(width: 60, height: 32, alignment: .center)
                .background(appearance.colorPalette.chatListUnreadMessageCountBackground)
                .cornerRadius(32/2)
                .padding(.trailing,5)
            }.padding(5)
            
            Spacer()
            // Separator line
            Rectangle()
                .fill(Color("#0E0F0C"))
                .frame(height: 1)
            
            // Button to send a message to the contact
            Button {
                UIApplication.shared.open(URL(string: "sms:\(index.contactIdentifier ?? "")")!, options: [:], completionHandler: nil)
            } label: {
                Text("Message")
                    .padding(.vertical,5)
                    .font(appearance.fonts.contactDetailButtons)
                    .foregroundColor(appearance.colorPalette.userProfileEditText)
                
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.vertical,10)
            
           
        }
        .frame(height: 131) // Set the height of the cell
        .background(Color(hex: "#F5F5F2")) // Background color for the cell
        .cornerRadius(16) // Rounded corners for the cell
    }
}
