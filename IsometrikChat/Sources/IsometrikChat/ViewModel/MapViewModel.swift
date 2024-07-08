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

class MapViewModel : NSObject, ObservableObject, CLLocationManagerDelegate{
    
    //MARK:  - PROPERTIES
    @Published var permissionDenied = false
    @Published var searchedText = ""
    var mapView: GMSMapView!
    @Published var location: CLLocation? {
        willSet { objectWillChange.send() }
    }
    var latitude: CLLocationDegrees {
        return location?.coordinate.latitude ?? 0
    }
    var longitude: CLLocationDegrees {
        return location?.coordinate.longitude ?? 0
    }
    
    private var placesClient = GMSPlacesClient.shared()
    // 2
    @Published var places = [GMSPlaceLikelihood]()
    
    
    //searching places
    func searchQuery(){
        
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
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
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        ISMChat_Helper.print(error.localizedDescription)
    }
    
    //getting user region
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else{
            return
        }
        self.location = location
        manager.stopUpdatingLocation()
    }
    
    func currentPlacesList(){
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

struct PlacesAutoCompleteResponse: Decodable {
    let predictions: [Prediction]
    
    struct Prediction: Decodable {
        let description: String
    }
}
