//
//  File.swift
//  
//
//  Created by Rasika Bharati on 05/09/24.
//

import Foundation
import SwiftUI
import IsometrikChat

//this view is only used for flexcrew project

struct JobCardView: View {
    var jobTitle: String = ""
    var jobId : String = ""
    var startDate : String = ""
    var endDate : String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Job Title
            Text(jobTitle)
                .font(.regular(size: 18))
                .foregroundColor(Color(hex: "#242A4B"))

            HStack {
                // Date Range with Icon
                HStack(spacing: 4) {
                    ISMChatSdkUI.getInstance().getAppAppearance().appearance.images.calanderLogo
                        .resizable()
                        .frame(width: 17, height: 17, alignment: .center)
                    Text(ISMChatHelper.formatDateRange(startDate: startDate, endDate: endDate) ?? "")
                        .font(.regular(size: 14))
                        .foregroundColor(Color(hex: "#858AA8"))
                }
                
                Spacer()
                
                Text("View details")
                    .font(.regular(size: 14))
                    .foregroundColor(Color(hex: "#0828D8"))
            }
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 15)
        .background(Color(.systemBlue).opacity(0.1))
    }
}
