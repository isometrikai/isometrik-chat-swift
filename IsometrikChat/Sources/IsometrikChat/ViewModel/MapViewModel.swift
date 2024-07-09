//
//  MapViewModel.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 31/05/23.
//

import Foundation
import SwiftUI
import CoreLocation
import GooglePlaces
import GoogleMaps
import Alamofire

public class MapViewModel : NSObject, ObservableObject, CLLocationManagerDelegate{
    
    //MARK:  - PROPERTIES
    @Published public var permissionDenied = false
    @Published public var searchedText = ""
    public var mapView: GMSMapView!
    @Published public var location: CLLocation? {
        willSet { objectWillChange.send() }
    }
    public var latitude: CLLocationDegrees {
        return location?.coordinate.latitude ?? 0
    }
    public var longitude: CLLocationDegrees {
        return location?.coordinate.longitude ?? 0
    }
    
    public var placesClient = GMSPlacesClient.shared()
    // 2
    @Published public var places = [GMSPlaceLikelihood]()
    
    
    //searching places
    func searchQuery(){
        
    }
    
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        //checking permissions
        switch manager.authorizationStatus{
        case .denied:
            //alert
            permissionDenied.toggle()
        case .notDetermined:
            //requesting
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            manager.requestLocation()
            manager.startUpdatingLocation()
            currentPlacesList()
        case .authorizedAlways:
            manager.requestLocation()
            manager.startUpdatingLocation()
            currentPlacesList()
        default:
            ()
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        ISMChat_Helper.print(error.localizedDescription)
    }
    
    //getting user region
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else{
            return
        }
        self.location = location
        manager.stopUpdatingLocation()
    }
    
    public func currentPlacesList(){
        // 3
        placesClient.currentPlace { (placeLikelyHoodList, error) in
            if let error = error {
                ISMChat_Helper.print("Places failed to initialize with error \(error)")
                return
            }
            guard let placeLikelyHoodList = placeLikelyHoodList else { return }
            self.places = placeLikelyHoodList.likelihoods
        }
    }
}

public struct PlacesAutoCompleteResponse: Decodable {
    public let predictions: [Prediction]
    
    public struct Prediction: Decodable {
        let description: String
    }
}
