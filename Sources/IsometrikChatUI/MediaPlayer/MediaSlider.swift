//
//  MediaSlider.swift
//  ISMChatSdk
//
//  Created by Rahul Iphone123 on 04/07/23.
//

import SwiftUI
import AVKit
import SDWebImageSwiftUI
import IsometrikChat


struct MediaSlider: View {
    
    var viewModel = ChatsViewModel()
    @State var index = 2
    @State var media = [MediaDB]()
    @EnvironmentObject var realmManager : RealmManager
    @Binding var description : String
    @Binding var user : String
    @State var userData = ISMChatSdk.getInstance().getChatClient().getConfigurations()
    
    var body: some View {
        GeometryReader { proxy in
            TabView(selection: $index) {
                ForEach(0..<(self.media.count ), id: \.self) { i in
                    
                    let userName = self.media[i].userName
                    VStack{
                        
                        let url = (self.media[i].mediaUrl )
                        
                        if self.media[i].customType == ISMChatMediaType.Video.value {
                            let vp =  AVPlayer(url:  URL(string: url)!)
                            VideoPlayer(player: vp)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .clipped()
                                .onAppear{vp.play()}
                                .onDisappear{vp.pause()}
                            
                        }else if media[i].customType == ISMChatMediaType.gif.value{
                            AnimatedImage(url: URL(string: url))
                                .resizable()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            ISMChatImageCahcingManger.networkImage(url: url,isprofileImage: false)
                                .resizable()
                                .scaledToFit()
                                .tag(i)
                                .modifier(ImageModifier(contentSize: CGSize(width: proxy.size.width, height: proxy.size.height)))
                        }
                        Spacer()
                        if !self.media[i].caption.isEmpty{
                            VStack(alignment: .leading){
                                Divider()
                                Text("\(self.media[i].caption)")
                                    .multilineTextAlignment(.leading)
                                    .foregroundColor(Color.black)
                                    .font(Font.regular(size: 16))
                                    .padding(.horizontal,15)
                            }
                        }
                       
                    }
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .onAppear(perform: {
                        let date = NSDate().doubletoDate(time: self.media[i].sentAt )
                        let time = NSDate().doubletoTime(time: self.media[i].sentAt )
                        let name = userName == userData.userConfig.userName ? ConstantStrings.you : userName
                        self.user = name
                        self.description = "\(date), \(time)"
                    })
                }
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
    }
}
