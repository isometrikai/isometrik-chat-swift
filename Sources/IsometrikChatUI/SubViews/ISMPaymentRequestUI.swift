//
//  Untitled.swift
//  IsometrikChat
//
//  Created by Rasika Bharati on 24/04/25.
//

import IsometrikChat
import SwiftUI

struct ISMPaymentRequestUI: View {
    var status: ISMChatPaymentRequestStatus
    var isReceived : Bool
    var message : MessagesDB
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    var viewDetails : () -> ()
    var declineRequest : () -> ()
    @State private var timer: Timer?
    @State private var totalTime : Int = 0
    @State private var remainingTime: TimeInterval = 0
    var userData = ISMChatSdk.getInstance().getChatClient()?.getConfigurations().userConfig
    var amount: AttributedString {
        let amountValue = String(format: "%.2f", message.metaData?.amount ?? 0.0)
        var attributedString = AttributedString("\(amountValue) \(message.metaData?.currencyCode ?? "")")
        attributedString.kern = -1.5
        if let range = attributedString.range(of: "\(amountValue)") {
            attributedString[range].foregroundColor = (status == .Rejected || status == .Expired)
                ? Color(hex: "#6A6C6A")
                : Color(hex: "#121511")
            attributedString[range].font = Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().semibold, size: 26)
        }
        return attributedString
    }
    var attributedTimerText: AttributedString {
        var attributedString = AttributedString("Payment request will expire in \(timeString(from: remainingTime))")
        
        // Style "clear chat"
        if let range = attributedString.range(of: "\(timeString(from: remainingTime))") {
            attributedString[range].foregroundColor = Color(hex: "#3A341C")
            attributedString[range].font = Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().semibold, size: 12).monospacedDigit()
        }
        
        return attributedString
    }
    
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            // Header and Payment Status
            headerView.padding(.bottom,16)
            
            appearance.images.paymentLogo
                .resizable()
                .frame(width: 70, height: 60, alignment: .center)
                .padding(.bottom,10)
            
            // Payment Amount
            VStack(spacing: 0) {
                payTextView
                
                Text(amount)
                    .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().light, size: 26))
                    .foregroundColor((status == .Rejected || status == .Expired) ? Color(hex: "#6A6C6A") : Color(hex: "#121511"))
                    .padding(.bottom,16)
                    .lineSpacing(32 - 26) // Line spacing calculated as (line height - font size)
                    .tracking(-0.015 * 26)
                
                // Conditional Messages Based on Status
                statusView
            }
            .padding(.horizontal, 24)
            
            // Action Buttons for Active Request Only
            buttonsView
        }.onAppear {
            totalTime = (message.metaData?.requestAPaymentExpiryTime ?? 0) * 60
            startTimer()
        }.onDisappear{
            stopTimer()
        }
    }
    
    private func startTimer() {
        let expirationTimestamp = (message.sentAt / 1000.0) + Double(totalTime)
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                let currentTimestamp = Date().timeIntervalSince1970
                remainingTime = max(0, expirationTimestamp - currentTimestamp)
                
                // Stop the timer when countdown reaches 0
                if remainingTime <= 0 {
                    timer.invalidate()
                }
            }
        }
        
        private func stopTimer() {
            timer?.invalidate()
            timer = nil
        }
        
    private func timeString(from remainingTime: TimeInterval) -> String {
        let hours = Int(remainingTime) / 3600
        let minutes = (Int(remainingTime) % 3600) / 60
        let seconds = Int(remainingTime) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    @ViewBuilder
    private var statusView : some View{
        if status == .ActiveRequest {
            Text(attributedTimerText)
                .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().regular, size: 12))
                .foregroundColor(Color(hex: "#3A341C")).padding(.bottom,16)
        } else if status == .Rejected && isReceived == false{
            HStack{
                Text("This payment request has been declined.")
                    .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().regular, size: 11))
                    .foregroundColor(Color(hex: "#6A6C6A")).padding(.bottom,16)
                Spacer()
            }
        } else if status == .Expired {
            HStack{
                Text("This payment request has expired.")
                    .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().semibold, size: 12))
                    .foregroundColor(Color(hex: "#6A6C6A")).padding(.bottom,16)
                Spacer()
            }
        }else if status == .Cancelled {
            HStack{
                if isReceived{
                    if let otherUserName = message.metaData?.paymentRequestedMembers.first(where: { $0.userId != userData?.userId && $0.status == 4 }) {
                        Text("\(otherUserName.userName ?? "") cancelled the payment request.")
                            .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().regular, size: 12))
                            .foregroundColor(Color(hex: "#6A6C6A")).padding(.bottom,16)
                    }else{
                        Text("This order has been cancelled.")
                            .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().regular, size: 12))
                            .foregroundColor(Color(hex: "#6A6C6A")).padding(.bottom,16)
                    }
                }else{
                    Text("You cancelled this order.")
                        .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().regular, size: 12))
                        .foregroundColor(Color(hex: "#6A6C6A")).padding(.bottom,16)
                }
                Spacer()
            }
        }else if let member = message.metaData?.paymentRequestedMembers, member.contains(where: { $0.userId != userData?.userId && $0.status == 1 }) && message.senderInfo?.userId != userData?.userId{
            Text("This payment request has already been completed.")
                .multilineTextAlignment(.center)
                .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().regular, size: 12))
                .foregroundColor(Color(hex: "#6A6C6A")).padding(.bottom,16)
        }
    }
    
    @ViewBuilder
    private var payTextView : some View{
        if status == .Accepted{
            Text("Total you paid")
                .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().regular, size: 12))
                .foregroundColor((status == .Rejected || status == .Expired) ? Color(hex: "#6A6C6A") : Color(hex: "#121511"))
        } else if status == .PayedByOther{
            if let member = message.metaData?.paymentRequestedMembers, member.contains(where: { $0.userId != userData?.userId && $0.status == 1 }) && message.senderInfo?.userId != userData?.userId{
                Text("Total you pay")
                    .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().regular, size: 12))
                    .foregroundColor((status == .Rejected || status == .Expired) ? Color(hex: "#6A6C6A") : Color(hex: "#121511"))
            }else{
                Text("Your friend paid")
                    .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().regular, size: 12))
                    .foregroundColor((status == .Rejected || status == .Expired) ? Color(hex: "#6A6C6A") : Color(hex: "#121511"))
            }
        }else{
            Text(isReceived ? "Total you pay" : "Total your friend pays")
                .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().regular, size: 12))
                .foregroundColor((status == .Rejected || status == .Expired) ? Color(hex: "#6A6C6A") : Color(hex: "#121511"))
        }
    }
    
    @ViewBuilder
    private var buttonsView : some View{
        if status == .ActiveRequest {
            HStack(spacing: 20) {
                if isReceived == true{
                    Button(action: {
                        declineRequest()
                    }) {
                        Text("Decline")
                            .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().semibold, size: 14))
                            .foregroundStyle(Color(hex: "#163300"))
                            .frame(width: 119, height: 32, alignment: .center)
                            .background(RoundedRectangle(cornerRadius: 16).stroke(Color(hex: "#163300"), lineWidth: 1))
                    }
                    
                    Button(action: {
                        viewDetails()
                    }) {
                        Text("View details")
                            .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().semibold, size: 14))
                            .foregroundStyle(Color(hex: "#163300"))
                            .frame(width: 119, height: 32, alignment: .center)
                            .background(Color(hex: "#86EA5D"))
                            .cornerRadius(16)
                    }
                }else{
                    Button(action: {
                        viewDetails()
                    }) {
                        Text("View details")
                            .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().semibold, size: 14))
                            .foregroundStyle(Color(hex: "#163300"))
                            .frame(width: 225, height: 32, alignment: .center)
                            .background(RoundedRectangle(cornerRadius: 16).stroke(Color(hex: "#163300"), lineWidth: 1))
                    }
                }
            }
            .padding(.horizontal, 24)
        }else if status == .Rejected{
            if isReceived == true{
                HStack(spacing: 20) {
                    Button(action: {
                        
                    }) {
                        Text("Declined")
                            .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().semibold, size: 14))
                            .foregroundStyle(Color(hex: "#6A6C6A"))
                            .frame(width: 119, height: 32, alignment: .center)
                            .background(Color(hex: "#dfdfdc"))
                            .cornerRadius(16)
                    }
                    
                    Button(action: {
                        viewDetails()
                    }) {
                        Text("View details")
                            .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().semibold, size: 14))
                            .foregroundStyle(Color(hex: "#163300"))
                            .frame(width: 119, height: 32, alignment: .center)
                            .background(RoundedRectangle(cornerRadius: 16).stroke(Color(hex: "#163300"), lineWidth: 1))
                    }
                }
                .padding(.horizontal, 24)
            }else{
                Button(action: {
                    viewDetails()
                }) {
                    Text("View Details")
                        .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().semibold, size: 14))
                        .foregroundStyle(Color(hex: "#163300"))
                        .frame(width: 225, height: 32, alignment: .center)
                        .background(RoundedRectangle(cornerRadius: 16).stroke(Color(hex: "#163300"), lineWidth: 1))
                }
            }
        }else if status == .PayedByOther{
            Button(action: {
                viewDetails()
            }) {
                Text("View Details")
                    .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().semibold, size: 14))
                    .foregroundStyle(Color(hex: "#163300"))
                    .frame(width: 225, height: 32, alignment: .center)
                    .background(RoundedRectangle(cornerRadius: 16).stroke(Color(hex: "#163300"), lineWidth: 1))
            }
        }else if status == .Accepted{
            HStack(spacing: 20){
                Button(action: {
                    // Decline action
                }) {
                    Text("Paid")
                        .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().semibold, size: 14))
                        .foregroundStyle(Color(hex: "#6A6C6A"))
                        .frame(width: 119, height: 32, alignment: .center)
                        .background(Color(hex: "#dfdfdc"))
                        .cornerRadius(16)
                }
                
                
                Button(action: {
                    viewDetails()
                }) {
                    Text("View Details")
                        .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().semibold, size: 14))
                        .foregroundStyle(Color(hex: "#163300"))
                        .frame(width: 119, height: 32, alignment: .center)
                        .background(RoundedRectangle(cornerRadius: 16).stroke(Color(hex: "#163300"), lineWidth: 1))
                }
            }.padding(.horizontal, 24).padding(.bottom,15)
        }else if status == .Expired || status == .Cancelled{
            Button(action: {
                viewDetails()
            }) {
                Text("View Details")
                    .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().semibold, size: 14))
                    .foregroundStyle(Color(hex: "#163300"))
                    .frame(width: 225, height: 32, alignment: .center)
                    .background(RoundedRectangle(cornerRadius: 16).stroke(Color(hex: "#163300"), lineWidth: 1))
            }
        }
    }
    
    // Header View Based on Status
    @ViewBuilder
    private var headerView: some View {
        if status == .ActiveRequest {
            if isReceived == true{
                Text("Payment Request Received")
                    .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().semibold, size: 16))
                    .foregroundColor(Color(hex: "#121511"))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "#86EA5D"))
                    .cornerRadius(10, corners: [.topLeft, .topRight])
            }else{
                Text("Payment Request Sent")
                    .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().semibold, size: 16))
                    .foregroundColor(Color(hex: "#121511"))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "#86EA5D"))
                    .cornerRadius(10, corners: [.topLeft, .topRight])
            }
        }else if status == .Accepted {
            Text("Payment Successful")
                .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().semibold, size: 16))
                .foregroundColor(Color(hex: "#121511"))
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(hex: "#86EA5D"))
                .cornerRadius(10, corners: [.topLeft, .topRight])
        } else if status == .PayedByOther {
            if let member = message.metaData?.paymentRequestedMembers, member.contains(where: { $0.userId != userData?.userId && $0.status == 1 }) && message.senderInfo?.userId != userData?.userId{
                Text("Request Closed")
                    .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().semibold, size: 16))
                    .foregroundColor(Color(hex: "#454745"))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "#BDBDBA"))
                    .cornerRadius(10, corners: [.topLeft, .topRight])
            }else{
                Text("Payment Received")
                    .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().semibold, size: 16))
                    .foregroundColor(Color(hex: "#121511"))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "#86EA5D"))
                    .cornerRadius(10, corners: [.topLeft, .topRight])
            }
        }else if status == .Rejected {
            Text(isReceived ? "Payment Request Declined" : "Payment Declined")
                .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().semibold, size: 16))
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(hex: "#FF3B30"))
                .cornerRadius(10, corners: [.topLeft, .topRight])
        } else if status == .Expired {
            Text(isReceived ? "Payment Expired" : "Payment Request Expired")
                .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().semibold, size: 16))
                .foregroundColor(Color(hex: "#454745"))
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(hex: "#BDBDBA"))
                .cornerRadius(10, corners: [.topLeft, .topRight])
        }else if status == .Cancelled {
            Text("Payment Request Cancelled")
                .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().semibold, size: 16))
                .foregroundColor(Color(hex: "#454745"))
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(hex: "#BDBDBA"))
                .cornerRadius(10, corners: [.topLeft, .topRight])
        }
    }
}
