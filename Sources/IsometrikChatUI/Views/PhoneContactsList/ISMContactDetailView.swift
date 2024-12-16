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
    let data : MetaDataDB
    @State private var presentContact : Bool = false
    @Environment(\.presentationMode) var presentationMode
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    
    //MARK: - BODY
    var body: some View {
        VStack{
            HStack{
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    appearance.images.backButton
                        .resizable()
                        .frame(width: appearance.imagesSize.backButton.width, height: appearance.imagesSize.backButton.height)
                })
                Spacer()
                
                Text("View Contacts")
                    .font(appearance.fonts.navigationBarTitle)
                    .foregroundColor(appearance.colorPalette.navigationBarTitle)
                
                Spacer()
                
                Button(action: {  }) {
                    Image("")
                        .resizable()
                        .frame(width: appearance.imagesSize.backButton.width, height: appearance.imagesSize.backButton.height)
                }
                
            }.padding(.horizontal,15)
            
            List{
                ForEach(data.contacts, id: \.self) { index in
                    ContactDetailCell(presentContact: $presentContact, index: index)
                }.listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .background(Color.white)
            .sheet(isPresented: $presentContact) {
                ContactSavingView()
            }
        }.navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
    }
}

struct ContactSavingView: View {
    //MARK: - PROPERTIES
    @State private var contact = CNMutableContact()
    @State private var phoneNumbers: [String] = [String()]
    @Environment(\.presentationMode) var presentationMode
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    
    //MARK: - BODY
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("First Name", text: $contact.givenName)
                    TextField("Last Name", text: $contact.familyName)
                }
                Section(header: Text("Phone Numbers")) {
                    ForEach(phoneNumbers.indices, id: \.self) { index in
                        TextField("Phone \(index + 1)", text: $phoneNumbers[index])
                    }
                    Button(action: {
                        phoneNumbers.append("")
                    }) {
                        Text("Add Phone Number")
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text("Add Contact")
                            .font(appearance.fonts.navigationBarTitle)
                            .foregroundColor(appearance.colorPalette.navigationBarTitle)
                    }
                }
            }
            .navigationBarItems(leading:
                                    Button(action: {
                presentationMode.wrappedValue.dismiss()
            }, label: {
                appearance.images.CloseSheet
                    .resizable()
                    .tint(.black)
                    .foregroundColor(.black)
                    .frame(width: 17,height: 17)
            }),
                                trailing:
                                    Button("Save") {
                saveContact()
            }
            )
        }.navigationViewStyle(StackNavigationViewStyle())
    }
    
    //MARK: - CONFIGURE
    func saveContact() {
        contact.phoneNumbers.removeAll()
        for number in phoneNumbers {
            let phoneNumber = CNLabeledValue(label: CNLabelPhoneNumberMain, value: CNPhoneNumber(stringValue: number))
            contact.phoneNumbers.append(phoneNumber)
        }
        
        let saveRequest = CNSaveRequest()
        saveRequest.add(contact, toContainerWithIdentifier: nil)
        do {
            try CNContactStore().execute(saveRequest)
            presentationMode.wrappedValue.dismiss()
        } catch {
            // Handle the error
        }
    }
}


struct ContactDetailCell : View {
    @Binding var presentContact : Bool
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    let index : ContactDB
    var body: some View {
        VStack(spacing:0){
            Spacer()
            HStack(spacing: 10){
                if let name = index.contactName{
                    UserAvatarView(avatar: "", showOnlineIndicator: false, userName: name)
                        .frame(width: 44, height: 44)
                        .clipShape(Circle())
                }
                VStack(alignment: .leading, spacing: 5, content: {
                    Text(index.contactName ?? "")
                        .font(appearance.fonts.contactDetailsTitle)
                        .foregroundColor(appearance.colorPalette.messageListHeaderTitle)
                    
                    if let phones = index.contactIdentifier {
                        Text(phones)
                            .font(appearance.fonts.contactDetailsNumber)
                            .foregroundColor(appearance.colorPalette.chatListUserMessage)
                    }
                })
                Spacer()
                
                Button {
                    presentContact = true
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
            Rectangle()
                .fill(Color("#0E0F0C"))
                .frame(height: 1)
            
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
        .frame(height: 131)
        .background(Color(hex: "#F5F5F2"))
        .cornerRadius(16)
    }
}
