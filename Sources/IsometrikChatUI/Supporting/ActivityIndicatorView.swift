//
//  ActivityIndicatorView.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 02/05/23.
//

import SwiftUI

struct ActivityIndicatorView: View {
    
    //MARK:  - PROPERTIES
    @Binding var isPresented:Bool
    
    //MARK:  - LIFECYCLE
    var body: some View {
        if isPresented == true{
            ZStack{
                Color(.systemBackground)
                    .ignoresSafeArea()
                    .opacity(0.3)
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .gray))
            }
        }
    }
}
