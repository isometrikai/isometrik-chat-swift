//
//  File.swift
//  
//
//  Created by Rasika Bharati on 05/09/24.
//

import Foundation
import SwiftUI
import IsometrikChat

/// A SwiftUI view that displays job information in a card format
/// This view is specifically designed for the FlexCrew project to show job details
struct JobCardView: View {
    // MARK: - Properties
    
    /// The title/name of the job position
    var jobTitle: String = ""
    
    /// Unique identifier for the job
    var jobId: String = ""
    
    /// Job start date in string format
    var startDate: String = ""
    
    /// Job end date in string format
    var endDate: String = ""

    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Display job title with specific styling
            Text(jobTitle)
                .font(.regular(size: 18))
                .foregroundColor(Color(hex: "#242A4B"))

            HStack {
                // Date range section with calendar icon
                HStack(spacing: 4) {
                    // Calendar icon from app appearance
                    ISMChatSdkUI.getInstance().getAppAppearance().appearance.images.calanderLogo
                        .resizable()
                        .frame(width: 17, height: 17, alignment: .center)
                    
                    // Formatted date range string
                    Text(ISMChatHelper.formatDateRange(startDate: startDate, endDate: endDate) ?? "")
                        .font(.regular(size: 14))
                        .foregroundColor(Color(hex: "#858AA8"))
                }
                
                Spacer()
                
                // "View details" link
                Text("View details")
                    .font(.regular(size: 14))
                    .foregroundColor(Color(hex: "#0828D8"))
            }
        }
        // Card styling
        .padding(.horizontal, 15)
        .padding(.vertical, 15)
        .background(Color(.systemBlue).opacity(0.1))
    }
}
