//
//  ISMMapDetailView.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 06/11/23.
//

import SwiftUI
import MapKit
import IsometrikChat

/// A SwiftUI view that displays a detailed map view with location information and sharing options
struct ISMMapDetailView: View {
    
    //MARK:  - PROPERTIES
    @Environment(\.dismiss) var dismiss
    
    /// The underlying MapKit view instance
    @State private var mapView = MKMapView()
    
    /// Controls the visibility of the share options bottom sheet
    @State private var showBottomSheet : Bool = false
    
    /// Location data containing coordinates and address information
    var data: ISMChatLocationData?
    
    /// Camera position for the map view
    @State var camera : MapCameraPosition = .automatic
    
    /// UI appearance configuration from the SDK
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    
    /// The map's visible region, initialized with default coordinates
    @State private var region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // Replace with your default coordinate
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05) // Adjust this for zoom level
        )
    
    //MARK:  - LIFECYCLE
    var body: some View {
        ZStack{
            VStack {
                HStack{
                    navigationBarLeadingButtons()
                    Spacer()
                    Text(data?.title ?? "")
                        .font(appearance.fonts.messageListMessageText)
                    Spacer()
                    navigationBarTrailingButtons()
                }.padding(.horizontal,15).padding(.bottom,5)
                Map(coordinateRegion: $region,interactionModes: [.all], showsUserLocation: true, annotationItems: [MapAnnotationItem(coordinate: region.center)]) { item in
                            MapAnnotation(coordinate: item.coordinate) {
                                appearance.images.mapPinLogo
                                    .resizable()
                                    .frame(width: 30, height: 30, alignment: .center)
                            }
                        }
                        .onAppear {
                            // Update the region to the desired zoom level if necessary
                            region = MKCoordinateRegion(
                                center: CLLocationCoordinate2D(latitude: data?.coordinate.latitude ?? 0, longitude: data?.coordinate.longitude ?? 0), // Replace with your default coordinate
                                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
                            updateRegion(for: data?.coordinate)
                        }
//                Map(){
//                    Annotation("", coordinate: data?.coordinate ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)) {
//                        appearance.images.mapPinLogo
//                            .resizable()
//                            .frame(width: 30, height: 30, alignment: .center)
//                    }
//                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 1){
                    Text(data?.title ?? "")
                        .font(appearance.fonts.messageListMessageText)
                        .foregroundColor(appearance.colorPalette.messageListHeaderTitle)
                    Text(data?.completeAddress ?? "")
                        .font(appearance.fonts.chatListUserMessage)
                        .foregroundColor(appearance.colorPalette.chatListUserMessage)
                }
            }
        }
        .navigationBarItems(leading: navigationBarLeadingButtons() , trailing: navigationBarTrailingButtons())
        .navigationBarBackButtonHidden()
        .confirmationDialog("Select an action", isPresented: $showBottomSheet, titleVisibility: .hidden) {
            attachmentActionSheetButtons()
        }
    }
    
    /// Updates the map's visible region based on the provided coordinate
    /// - Parameter coordinate: The coordinate to center the map on
    func updateRegion(for coordinate: CLLocationCoordinate2D?) {
        if let coordinate = coordinate {
            region = MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            )
        }
    }
    
    //MARK: - CONFIGURE
    /// Creates the navigation bar's trailing button (share button)
    func navigationBarTrailingButtons() -> some View{
        Button(action: {
            showBottomSheet = true
        }, label: {
            appearance.images.share
                .resizable()
                .frame(width: 18, height: 20)
                .imageScale(.large)
                .foregroundStyle(Color.blue)
        }).padding(.leading)
    }
    
    /// Creates the navigation bar's leading button (back button)
    func navigationBarLeadingButtons() -> some View{
        HStack{
            Button(action: {
                dismiss()
            }) {
                appearance.images.backButton
                    .resizable()
                    .frame(width: appearance.imagesSize.backButton.width, height: appearance.imagesSize.backButton.height)
                    .imageScale(.large)
            }
        }
    }
    
    /// Creates the action sheet buttons for opening different map applications
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
    
    /// Opens the location in Google Maps app or web browser
    /// If the Google Maps app is installed, opens there, otherwise falls back to browser
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
    
    /// Opens the location in Apple Maps
    /// Creates a map item with the location data and launches Apple Maps with the specified options
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

/// Model representing a custom map annotation with unique identifier
struct CustomAnnotation1: Identifiable {
    var id: UUID
    var annotation: MKPointAnnotation
}

/// Model representing a map annotation item with coordinate information
struct MapAnnotationItem: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}
