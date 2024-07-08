//
//  ISMLocation.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 06/11/23.
//

import Foundation
import MapKit
import GoogleMaps

struct ISMChat_Landmark : Equatable{
    
    let placemark: MKPlacemark?
    
    var id: UUID {
        return UUID()
    }
    
    var name: String {
        self.placemark?.name ?? ""
    }
    
    var title: String {
        self.placemark?.title ?? ""
    }
    
    var coordinate: CLLocationCoordinate2D {
        self.placemark?.coordinate ?? CLLocationCoordinate2D()
    }
}

final class LandmarkAnnotation: NSObject, MKAnnotation {
    let title: String?
    let coordinate: CLLocationCoordinate2D

    init(landmark: ISMChat_Landmark) {
        self.title = landmark.name
        self.coordinate = landmark.coordinate
    }
}


struct ISMChat_LocationData{
    let coordinate : CLLocationCoordinate2D
    let title : String
    let completeAddress : String
    
    init(coordinate: CLLocationCoordinate2D? = nil, title: String? = nil, completeAddress: String? = nil) {
        self.coordinate = coordinate ?? CLLocationCoordinate2D()
        self.title = title ?? ""
        self.completeAddress = completeAddress ?? ""
    }
}
