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

/// A SwiftUI view that displays a location on a map with a custom pin
/// This view supports both static map images and interactive map functionality
struct ISMLocationSubView: View {
    
    //MARK:  - PROPERTIES
    /// Region to display on the map
    @State private var region: MKCoordinateRegion
    /// Google Maps marker for location indication
    @State private var markers: GMSMarker?
    /// Flag to control map interaction
    @State private var isMapInteractive = true
    /// Cached static map image
    @State private var mapImage: UIImage?
    /// Location coordinates
    @State private var latitude: Double?
    @State private var longitute: Double?  // Note: Typo in 'longitude'
    /// UI appearance configuration
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    
    /// Initializes the location view with message data
    /// - Parameter message: Message object containing location information
    init(message: MessagesDB) {
        // Extract location coordinates from message attachments
        if let latitude = message.attachments.first?.latitude, 
           let longitude = message.attachments.first?.longitude {
            // Initialize marker at the specified coordinates
            self.markers = GMSMarker(position: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
            self.latitude = latitude
            self.longitute = longitude
            // Set initial map region with zoom level
            self.region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        } else {
            // Fallback to default location (London) if coordinates are missing
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
                    
                
                appearance.images.mapPinLogo
                    .resizable()
                    .frame(width: appearance.imagesSize.mapPinLogo.width,height: appearance.imagesSize.mapPinLogo.height)
                    .scaledToFit()
            }
        }
        .onAppear {
            fetchMapImage()
        }
    }
    
    /// Generates and caches a static map image
    private func fetchMapImage() {
        let mapSnapshotOptions = MKMapSnapshotter.Options()
        
        // Configure map snapshot with location and display options
        let location = CLLocationCoordinate2D(latitude: latitude ?? 0, longitude: longitute ?? 0)
        let region = MKCoordinateRegion(
            center: location,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        
        // Configure snapshot parameters
        mapSnapshotOptions.region = region
        mapSnapshotOptions.size = CGSize(width: 350, height: 200)
        mapSnapshotOptions.showsBuildings = true
        
        // Generate map snapshot
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

/// Model representing a map annotation with unique identifier
struct CustomAnnotation: Identifiable {
    var id = UUID()
    var coordinate: CLLocationCoordinate2D
}

/// UIViewRepresentable wrapper for Google Maps view
struct GoogleMapsView: UIViewRepresentable {

    // MARK: - PROPERTIES
    private let zoom: Float = 15.0
    var markers: GMSMarker
    var latitude: Double?
    var longitude: Double?

    // MARK: - LIFECYCLE
    func makeUIView(context: Self.Context) -> GMSMapView {
        // Create the camera with the given latitude, longitude, and zoom
        let camera = GMSCameraPosition.camera(withLatitude: latitude ?? 0, longitude: longitude ?? 0, zoom: zoom)
        
        // Initialize GMSMapView using the recommended initializer
        let mapView = GMSMapView()
        mapView.camera = camera
        mapView.isUserInteractionEnabled = false
        mapView.selectedMarker = markers
        return mapView
    }

    func updateUIView(_ mapView: GMSMapView, context: Context) {
        let marker = GMSMarker()
        marker.position = markers.position
        marker.map = mapView
    }
}

