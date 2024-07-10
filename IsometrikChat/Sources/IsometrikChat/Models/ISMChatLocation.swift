//
//  ISMLocation.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 06/11/23.
//

import Foundation
import MapKit
import GoogleMaps

struct ISMChatLandmark : Equatable{
    
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

    init(landmark: ISMChatLandmark) {
        self.title = landmark.name
        self.coordinate = landmark.coordinate
    }
}


public struct ISMChatLocationData{
    public let coordinate : CLLocationCoordinate2D
    public let title : String
    public let completeAddress : String
    
    public init(coordinate: CLLocationCoordinate2D? = nil, title: String? = nil, completeAddress: String? = nil) {
        self.coordinate = coordinate ?? CLLocationCoordinate2D()
        self.title = title ?? ""
        self.completeAddress = completeAddress ?? ""
    }
}
