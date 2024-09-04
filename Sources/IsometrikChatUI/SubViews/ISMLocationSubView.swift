//
//  ISMLocationSubView.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 02/06/23.
//

import SwiftUI
import MapKit
import CoreLocation
import GooglePlaces
import GoogleMaps
import CoreLocation
import IsometrikChat

struct ISMLocationSubView: View {
    
    //MARK:  - PROPERTIES
    @State private var region: MKCoordinateRegion
    @State private var markers: GMSMarker?
    @State private var isMapInteractive = true
    @State private var mapImage: UIImage?
    @State private var latitude : Double?
    @State private var longitute : Double?
    @State private var themeImage = ISMChatSdkUI.getInstance().getAppAppearance().appearance.images
    
    init(message : MessagesDB) {
        if let latitude = message.attachments.first?.latitude, let longitude = message.attachments.first?.longitude {
            self.markers = GMSMarker(position: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
            // Create a region centered around the marker's coordinates
            self.latitude = latitude
            self.longitute = longitude
            self.region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01) // Adjust the delta values for your desired zoom level
            )
        } else {
            // Default to London City if no coordinates are provided
            self.region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 51.5, longitude: -0.12),
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            )
        }
    }
    
    
    //MARK:  - LIFECYCLE
    var body: some View {
        //        VStack{
        ////            GoogleMapsView(markers: markers!,latitude: latitude,longitude: longitude)
        //
        //            Map(coordinateRegion: $region, showsUserLocation: false, userTrackingMode: .constant(.follow), annotationItems: markers != nil ? [CustomAnnotation(coordinate: region.center)] : []) { location in
        //                            MapPin(coordinate: location.coordinate, tint: .red)
        //                        }
        //                        .disabled(true)
        //
        //        }
        ZStack {
            if let mapImage = mapImage {
                Image(uiImage: mapImage)
                    .resizable()
                    .scaledToFit()
                    
                
                themeImage.mapPinLogo
                    .resizable()
                    .frame(width: 30,height: 30)
            }
        }
        .onAppear {
            fetchMapImage()
        }
    }
    
    private func fetchMapImage() {
        let mapSnapshotOptions = MKMapSnapshotter.Options()
        
        let location = CLLocationCoordinate2D(latitude: latitude ?? 0, longitude: longitute ?? 0)
        
        // Adjust the span to zoom in or out
        let region = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        mapSnapshotOptions.region = region
        mapSnapshotOptions.size = CGSize(width: 350, height: 200) // Adjust the size as needed
        mapSnapshotOptions.showsBuildings = true
        
        let snapshotter = MKMapSnapshotter(options: mapSnapshotOptions)
        snapshotter.start { snapshot, error in
            guard let snapshot = snapshot, error == nil else {
                print("Error generating map snapshot: \(error?.localizedDescription ?? "")")
                return
            }
            
            mapImage = snapshot.image
        }
    }
    
}

struct CustomAnnotation: Identifiable {
    var id = UUID()
    var coordinate: CLLocationCoordinate2D
}


struct GoogleMapsView: UIViewRepresentable {
    
    //MARK:  - PROPERTIES
    private let zoom: Float = 15.0
    var markers: GMSMarker
    var latitude : Double?
    var longitude : Double?
    
    //MARK:  - LIFECYCLE
    func makeUIView(context: Self.Context) -> GMSMapView {
        let camera = GMSCameraPosition.camera(withLatitude: latitude ?? 0, longitude: longitude ?? 0, zoom: zoom)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.isUserInteractionEnabled = false
        mapView.selectedMarker = markers
        return mapView
    }
    
    func updateUIView(_ mapView: GMSMapView, context: Context) {
        let marker : GMSMarker = GMSMarker()
        marker.position = markers.position
        marker.map = mapView
    }
}
