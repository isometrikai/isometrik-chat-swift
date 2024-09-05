//
//  File.swift
//  
//
//  Created by Rasika Bharati on 05/09/24.
//

import Foundation
import SwiftUI

//this view is only used for flexcrew project

struct JobCardView: View {
    var jobTitle: String = "Hire an experienced handyman in Austin, TX"
    var dateRange: String = "10 October - 10 December"

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Job Title
            Text(jobTitle)
                .font(.regular(size: 18))
                .foregroundColor(Color(hex: "#242A4B"))

            HStack {
                // Date Range with Icon
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .foregroundColor(.gray)
                    Text(dateRange)
                        .font(.regular(size: 14))
                        .foregroundColor(Color(hex: "#858AA8"))
                }
                
                Spacer()
                
                Button(action: {
                    
                }, label: {
                    // View Details Link
                    Text("View details")
                        .font(.regular(size: 14))
                        .foregroundColor(Color(hex: "#0828D8"))
                })
            }
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 15)
        .background(Color(.systemBlue).opacity(0.1))
        .frame(height: 101)
    }
}

struct JobCardView_Previews: PreviewProvider {
    static var previews: some View {
        JobCardView()
            .previewLayout(.sizeThatFits)
    }
}
