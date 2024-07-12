//
//  PullToRefresh.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 14/03/23.
//

import Foundation
import SwiftUI

struct PullToRefresh: View {
    
    //MARK:  - PROPERTIES
    var coordinateSpaceName: String
    var onRefresh: ()->Void
    @State var needRefresh: Bool = false
    
    //MARK:  - LIFECYCLE
    var body: some View {
        GeometryReader { geo in
            if (geo.frame(in: .named(coordinateSpaceName)).midY > 50) {
                Spacer()
                    .onAppear {
                        needRefresh = true
                    }
            } else if (geo.frame(in: .named(coordinateSpaceName)).maxY < 10) {
                Spacer()
                    .onAppear {
                        if needRefresh {
                            needRefresh = false
                            onRefresh()
                        }
                    }
            }
            HStack {
                Spacer()
                if needRefresh {
                    ProgressView()
                } else {
                    Text("⬇️")
                }
                Spacer()
            }
        }.padding(.top, -50)
    }
}
