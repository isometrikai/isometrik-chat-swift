//
//  Untitled.swift
//  IsometrikChat
//
//  Created by Rasika Bharati on 24/04/25.
//
import SwiftUI
import IsometrikChat

struct ISMDineInRequestUI: View {
    var status: ISMChatPaymentRequestStatus
    var isReceived : Bool
    var message : MessagesDB
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    var viewDetails : () -> ()
    var declineRequest : () -> ()
    var showInvitee : () -> ()
    var userData = ISMChatSdk.getInstance().getChatClient()?.getConfigurations().userConfig
    @State private var isDeclineDisabled = false
    @State private var isAcceptDisabled = false
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            // Header and Payment Status
            headerView
                .padding(.bottom,16)
            
            
            // Payment Amount
            
                VStack(alignment: .leading,spacing: 8) {
                    
                    Text(message.metaData?.inviteTitle ?? "")
                        .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().semibold, size: 18))
                        .foregroundColor(Color(hex: "#121511"))
                        .padding(.bottom,16)
                    
                    HStack(alignment: .center, spacing: 8) {
                        
                        appearance.images.clockLogo
                            .resizable()
                            .frame(width: 18, height: 18, alignment: .center)
                        if status == .Rescheduled{
                            Text(formatTimestamp(message.metaData?.inviteRescheduledTimestamp ?? 0))
                                .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().regular, size: 14))
                                .foregroundColor(Color(hex: "#454745"))
                        }else{
                            Text(formatTimestamp(message.metaData?.inviteTimestamp ?? 0))
                                .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().regular, size: 14))
                                .foregroundColor(Color(hex: "#454745"))
                                .strikethrough(status == .Cancelled ? true : false, color: Color(hex: "#454745"))
                        }
                        
                    }
                    
                    if status == .Rescheduled{
                        HStack(alignment: .center, spacing: 8) {

                            Image("")
                                .resizable()
                                .frame(width: 18, height: 18, alignment: .center)
                            
                            Text(formatTimestamp(message.metaData?.inviteTimestamp ?? 0))
                                .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().regular, size: 14))
                                .foregroundColor(Color(hex: "#454745"))
                                .strikethrough(true, color: Color(hex: "#454745"))
                        }
                    }
                    
                    
                    
                    HStack(alignment: .center, spacing: 8) {
                        appearance.images.locationMapLogo
                            .resizable()
                            .frame(width: 16.71, height: 20.31, alignment: .center)
                        
                        var attributedText: AttributedString {
                            var attributedString = AttributedString("\(message.metaData?.inviteLocation?.name ?? "") Open Map")
                            
                            // Style "clear chat"
                            if let range = attributedString.range(of: "Open Map") {
                                attributedString[range].foregroundColor = Color(hex: "#454745")
                                attributedString[range].font = Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().semibold, size: 14)
                                attributedString[range].underlineStyle = .single
                            }
                            
                            return attributedString
                        }
                        
                        Text(attributedText)
                            .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().regular, size: 14))
                            .foregroundColor(Color(hex: "#454745"))
                            .onTapGesture {
                                if let range = attributedText.range(of: "Open Map") {
                                    print("Open Map tapped!")
                                    openMaps()
                                }
                            }
                    }
                    
                    if let memebersInvited = message.metaData?.inviteMembers{
                        Button {
                            showInvitee()
                        } label: {
                            HStack(spacing: 4){
                                ForEach(0..<min(memebersInvited.count, 4), id: \.self) { index in
                                    ZStack{
                                        let placeholderView = appearance.images.defaultImagePlaceholderForNormalUser?.resizable().scaledToFit()
                                        ISMChatImageCahcingManger.networkImage(url: memebersInvited[index].userProfileImage ?? "", isProfileImage: true, placeholderView: placeholderView)
                                            .scaledToFill()
                                            .frame(width: 25, height: 25)
                                            .clipShape(Circle())
                                    }
                                }
                            }.padding(.bottom,16)
                        }
                    }
                    
                    if status == .Expired{
                        HStack{
                            Spacer()
                            Text("Expired")
                                .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().semibold, size: 12))
                                .foregroundColor(Color(hex: "#6A6C6A"))
                            Spacer()
                        }
                    }
                    
                    if isReceived == false{
                        Text("You've sent a Dine-in invite. Please wait for your friend's response.")
                            .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().regular, size: 12))
                            .foregroundColor(Color(hex: "#3A341C"))
                    }
                    else if status == .Cancelled{
                        Text(isReceived ? "This dine-in reservation is cancelled." : "You've cancelled the Dine-in reservation.")
                            .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().regular, size: 12))
                            .foregroundColor(Color(hex: "#3A341C"))
                    }else if status == .Rescheduled{
                        Text(isReceived ? "Your friend has rescheduled Dine-in invite." : "You've rescheduled Dine-in invite. Please wait for your friend's response.")
                            .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().regular, size: 12))
                            .foregroundColor(Color(hex: "#3A341C"))
                    }
                    
                }.padding(.horizontal, 20)
            
            // Action Buttons for Active Request Only
            if status == .ActiveRequest {
                HStack(spacing: 20) {
                    if isReceived == true{
                        
                        Button(action: {
                            guard !isDeclineDisabled else { return }
                            isDeclineDisabled = true
                            declineRequest()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                isDeclineDisabled = false
                            }
                        }) {
                            Text("Can’t attend")
                                .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().semibold, size: 14))
                                .foregroundStyle(Color(hex: "#163300"))
                                .frame(width: 121, height: 32, alignment: .center)
                                .background(RoundedRectangle(cornerRadius: 16).stroke(Color(hex: "#163300"), lineWidth: 1))
                        }.disabled(isDeclineDisabled)
                        
                        Button(action: {
                            guard !isAcceptDisabled else { return }
                            isAcceptDisabled = true
                            viewDetails()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                isAcceptDisabled = false
                            }
                        }) {
                            Text("Accept")
                                .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().semibold, size: 14))
                                .foregroundStyle(Color(hex: "#163300"))
                                .frame(width: 121, height: 32, alignment: .center)
                                .background(RoundedRectangle(cornerRadius: 16).stroke(Color(hex: "#163300"), lineWidth: 1))
                        }.disabled(isAcceptDisabled)
                        
                    }
                }.padding(.horizontal, 16)
            }else if status == .Rejected{
                Button(action: {
                    
                }) {
                    Text("Declined")
                        .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().semibold, size: 14))
                        .foregroundStyle(Color(hex: "#6A6C6A"))
                        .frame(width: 225, height: 32, alignment: .center)
                        .background(Color(hex: "#dfdfdc"))
                        .cornerRadius(16)
                }
            }else if status == .Accepted{
                Button(action: {
                    
                }) {
                    Text("Accepted")
                        .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().semibold, size: 14))
                        .foregroundStyle(Color(hex: "#6A6C6A"))
                        .frame(width: 225, height: 32, alignment: .center)
                        .background(Color(hex: "#dfdfdc"))
                        .cornerRadius(16)
                }
            }
        }
    }
    
    func openMaps() {
        let url = "http://maps.apple.com/maps?saddr=\(message.metaData?.inviteLocation?.latitude ?? 0),\(message.metaData?.inviteLocation?.longitude ?? 0)"
        UIApplication.shared.open(URL(string : url)!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
    }
    
    fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
        return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
    }
    
    func formatTimestamp(_ timestamp: TimeInterval) -> String {
        // Convert the timestamp to a Date object
        let date = Date(timeIntervalSince1970: timestamp)
        
        // Create a DateFormatter
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        // Format the day with an ordinal suffix
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "d"
        let day = dayFormatter.string(from: date)
        
        let ordinalSuffix: String
        switch Int(day)! {
        case 1, 21, 31:
            ordinalSuffix = "st"
        case 2, 22:
            ordinalSuffix = "nd"
        case 3, 23:
            ordinalSuffix = "rd"
        default:
            ordinalSuffix = "th"
        }
        
        // Format the rest of the date
        formatter.dateFormat = "MMMM, yyyy • h:mm a"
        let formattedDate = formatter.string(from: date)
        
        // Combine day with the ordinal suffix and the formatted date
        return "\(day)\(ordinalSuffix) \(formattedDate)"
    }

    @ViewBuilder
    private var headerView: some View {
        if status == .ActiveRequest || status == .Expired{
            Text(isReceived ? "You're Invited!" : "Dine-in Invite")
                .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().semibold, size: 16))
                .foregroundColor(Color(hex: "#121511"))
                .frame(height: 73)
                .frame(maxWidth: .infinity)
                .background(status == .Expired ? Color(hex: "#BDBDBA") : Color(hex: "#86EA5D"))
                .cornerRadius(10, corners: [.topLeft, .topRight])
        }else if status == .Cancelled{
            Text(isReceived ? "Dine-in Invite - Cancelled" : "Dine-in Invite")
                .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().semibold, size: 16))
                .foregroundColor(Color.white)
                .frame(height: 73)
                .frame(maxWidth: .infinity)
                .background(Color(hex: "#FF3B30"))
                .cornerRadius(10, corners: [.topLeft, .topRight])
        }else if status == .Rejected{
            Text("You're Invited!")
                .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().semibold, size: 16))
                .foregroundColor(Color.white)
                .frame(height: 73)
                .frame(maxWidth: .infinity)
                .background(Color(hex: "#FF3B30"))
                .cornerRadius(10, corners: [.topLeft, .topRight])
        }else if status == .Accepted{
            Text("You're Invited!")
                .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().semibold, size: 16))
                .foregroundColor(Color(hex: "#121511"))
                .frame(height: 73)
                .frame(maxWidth: .infinity)
                .background(Color(hex: "#86EA5D"))
                .cornerRadius(10, corners: [.topLeft, .topRight])
        }else if status == .Rescheduled{
            Text(isReceived ? "You're Invited! - Rescheduled" : "Dine-in Invite - Rescheduled")
                .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().semibold, size: 16))
                .foregroundColor(Color(hex: "#121511"))
                .frame(height: 73)
                .frame(maxWidth: .infinity)
                .background(Color(hex: "#86EA5D"))
                .cornerRadius(10, corners: [.topLeft, .topRight])
        }
    }
}
