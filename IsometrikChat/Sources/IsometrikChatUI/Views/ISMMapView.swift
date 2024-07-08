//
//  ISMMapView.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 31/05/23.
//

import SwiftUI
import GoogleMaps

struct MapView: UIViewRepresentable {
    
    //MARK:  - PROPERTIES
    @EnvironmentObject var mapData : MapViewModel
    let marker : GMSMarker = GMSMarker()
    private let zoom: Float = 15.0
    
    //MARK:  - LIFECYCLE
    func makeUIView(context: Self.Context) -> GMSMapView {
        let camera = GMSCameraPosition.camera(withLatitude: mapData.latitude, longitude: mapData.longitude, zoom: zoom)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        return mapView
    }
    
    func updateUIView(_ mapView: GMSMapView, context: Context) {
        let camera = GMSCameraPosition.camera(withLatitude: mapData.latitude, longitude: mapData.longitude, zoom: zoom)
        mapView.camera = camera
        let currentLocation = CLLocationCoordinate2D(latitude: mapData.latitude, longitude: mapData.longitude)
        
        // Check for a valid location before updating the marker
        if isValidLocation(location: currentLocation) {
            mapView.animate(toLocation: currentLocation)
            marker.position = currentLocation
            marker.map = mapView
        } else {
            // Handle the case when the location is not valid (e.g., outside bounds)
            // You can show an alert or take appropriate action here.
            
            print("Location error")
        }
    }

    func isValidLocation(location: CLLocationCoordinate2D) -> Bool {
        // Define a reasonable bounds for valid locations (latitude and longitude ranges)
        let minLatitude: Double = -90.0
        let maxLatitude: Double = 90.0
        let minLongitude: Double = -180.0
        let maxLongitude: Double = 180.0

        return (minLatitude...maxLatitude).contains(location.latitude) &&
               (minLongitude...maxLongitude).contains(location.longitude)
    }

}
