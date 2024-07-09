//
//  ISMMapDetailView.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 06/11/23.
//

import SwiftUI
import MapKit
import IsometrikChat

struct ISMMapDetailView: View {
    
    //MARK:  - PROPERTIES
    @Environment(\.dismiss) var dismiss
    @State private var mapView = MKMapView()
    @State private var showBottomSheet : Bool = false
    var data: ISMChat_LocationData?
    @State var camera : MapCameraPosition = .automatic
    @State var themeFonts = ISMChatSdk.getInstance().getAppAppearance().appearance.fonts
    @State var themeColor = ISMChatSdk.getInstance().getAppAppearance().appearance.colorPalette
    @State var themeImage = ISMChatSdk.getInstance().getAppAppearance().appearance.images
    
    //MARK:  - LIFECYCLE
    var body: some View {
        ZStack{
            VStack {
                Map(){
                    Annotation("", coordinate: data?.coordinate ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)) {
                        themeImage.mapPinLogo
                            .resizable()
                            .frame(width: 30, height: 30, alignment: .center)
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 1){
                    Text(data?.title ?? "")
                        .font(themeFonts.messageList_MessageText)
                        .foregroundColor(themeColor.messageList_MessageText)
                    Text(data?.completeAddress ?? "")
                        .font(themeFonts.chatList_UserMessage)
                        .foregroundColor(themeColor.chatList_UserMessage)
                }
            }
        }
        .navigationBarItems(leading: navigationBarLeadingButtons() , trailing: navigationBarTrailingButtons())
        .navigationBarBackButtonHidden()
        .confirmationDialog("Select an action", isPresented: $showBottomSheet, titleVisibility: .hidden) {
            attachmentActionSheetButtons()
        }
    }
    
    //MARK: - CONFIGURE
    func navigationBarTrailingButtons() -> some View{
        Button(action: {
            showBottomSheet = true
        }, label: {
            themeImage.share
                .foregroundStyle(Color.blue)
        }).padding(.leading)
    }
    
    func navigationBarLeadingButtons() -> some View{
        HStack{
            Button(action: {
                dismiss()
            }) {
                themeImage.backButton
                    .resizable()
                    .frame(width: 29, height: 29)
                    .imageScale(.large)
            }
        }
    }
    
    func attachmentActionSheetButtons() -> some View{
        VStack{
            Button(action: {
                openAppleMap()
            }, label: {
                Text("Open in Maps")
            })
            Button(action: {
                openGoogleMap()
            }, label: {
                Text("Open in Google Map")
            })
        }
    }
    
    func openGoogleMap() {
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {  //if phone has an app
            if let url = URL(string: "comgooglemaps-x-callback://?saddr=&daddr=\(self.data?.coordinate.latitude ?? 0.0),\(self.data?.coordinate.longitude ?? 0.0)&directionsmode=driving") {
                UIApplication.shared.open(url, options: [:])
            }
        }
        else {
            //Open in browser
            if let urlDestination = URL.init(string: "https://www.google.co.in/maps/dir/?saddr=&daddr=\(self.data?.coordinate.latitude ?? 0.0),\(self.data?.coordinate.longitude ?? 0.0)&directionsmode=driving") {
                UIApplication.shared.open(urlDestination)
            }
        }
    }
    
    func openAppleMap(){
        let latitude: CLLocationDegrees = self.data?.coordinate.latitude ?? 0.0
        let longitude: CLLocationDegrees = self.data?.coordinate.longitude ?? 0.0
        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = data?.title
        mapItem.openInMaps(launchOptions: options)
    }
}


struct CustomAnnotation1: Identifiable {
    var id: UUID
    var annotation: MKPointAnnotation
}
