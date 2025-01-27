//
//  ISMLocationShareView.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 31/05/23.
//

import SwiftUI
import MapKit
import CoreLocation
import GooglePlaces
import Combine
import IsometrikChat

/// A SwiftUI view that handles location sharing functionality
/// This view provides both current location sharing and place search capabilities
struct ISMLocationShareView: View {
    // MARK: - PROPERTIES
    @Environment(\.dismiss) var dismiss
    
    // View Models and Location Management
    @StateObject private var mapViewModel = MapViewModel()
    @StateObject private var locationManager = LocationManager()
    
    // UI State Properties
    @State private var showSheet = true
    @State private var isTextFieldFocused: Bool = false
    @State private var searchText = ""
    @State private var predictions: [GMSAutocompletePrediction] = []
    @State private var selectedPlaceAfterSearch: GMSPlace?
    
    // Binding Properties for Location Data
    @Binding var longitude: Double?
    @Binding var latitude: Double?
    @Binding var placeId: String?
    @Binding var placeName: String?
    @Binding var address: String?
    
    // Configuration Properties
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    let chatproperties = ISMChatSdkUI.getInstance().getChatProperties()
    // Session token for Google Places API requests
    var sessionToken: GMSAutocompleteSessionToken = GMSAutocompleteSessionToken()

    
    // MARK: - LIFECYCLE
    var body: some View {
        ZStack {
           
            VStack(alignment: .leading, spacing: 15) {
                
                HStack{
                    if isTextFieldFocused == false{
                        navBarLeadingBtn
                    }else{
                        Image("")
                            .resizable()
                            .frame(width: appearance.imagesSize.backButton.width, height: appearance.imagesSize.backButton.height)
                    }
                    Spacer()
                    
                    Text("Share Location")
                        .font(appearance.fonts.navigationBarTitle)
                        .foregroundColor(appearance.colorPalette.navigationBarTitle)
                    
                    Spacer()
                    
                    if chatproperties.shareOnlyCurrentLocation == true{
                        Button(action: {  }) {
                            Image("")
                                .resizable()
                                .frame(width: appearance.imagesSize.backButton.width, height: appearance.imagesSize.backButton.height)
                        }
                    }else{
                        if isTextFieldFocused == false{
                            navBarTrailingBtn
                        } else{
                            Button(action: {  }) {
                                Image("")
                                    .resizable()
                                    .frame(width: appearance.imagesSize.backButton.width, height: appearance.imagesSize.backButton.height)
                            }
                        }
                    }
                    
                }.padding(.horizontal,15)
                
                if chatproperties.shareOnlyCurrentLocation == false{
                    CustomSearchBar(searchText: $searchText, isDisabled: false).padding(.horizontal,15)
                }
                
                if isTextFieldFocused == false{
                    mapView(coordinate: CLLocationCoordinate2D(latitude: locationManager.location?.coordinate.latitude ?? 0.0, longitude: locationManager.location?.coordinate.longitude ?? 0.0))
                        .frame(height: 300)
                    if chatproperties.shareOnlyCurrentLocation == false{
                        nearByPlacesListView()
                    }else{
                            Button {
                                self.longitude = mapViewModel.places.first?.place.coordinate.longitude
                                self.latitude = mapViewModel.places.first?.place.coordinate.latitude
                                self.placeId = mapViewModel.places.first?.place.placeID
                                self.placeName = mapViewModel.places.first?.place.name
                                self.address = mapViewModel.places.first?.place.formattedAddress
                                self.dismiss()
                            } label: {
                                HStack(spacing:17){
                                    appearance.images.mapTarget
                                        .resizable()
                                        .frame(width: 40,height: 40)
                                    Text("Use my current location")
                                        .foregroundColor(Color(hex: "#0E0F0C"))
                                        .font(appearance.fonts.locationMessageTitle)
                                }
                            }.padding(.horizontal,15)
                            
                            Button {
                                self.longitude = self.mapViewModel.places.first?.place.coordinate.longitude
                                self.latitude = self.mapViewModel.places.first?.place.coordinate.latitude
                                self.placeId = self.mapViewModel.places.first?.place.placeID
                                self.placeName = self.mapViewModel.places.first?.place.name
                                self.address = self.mapViewModel.places.first?.place.formattedAddress
                                self.dismiss()
                            } label: {
                                HStack(spacing:17){
                                    appearance.images.locationLogo
                                        .resizable()
                                        .frame(width: 40, height: 40, alignment: .center)
                                    VStack(alignment: .leading){
                                        Text("Use this location")
                                            .foregroundColor(Color(hex: "#0E0F0C"))
                                            .font(appearance.fonts.locationMessageTitle)
                                        Text(self.mapViewModel.places.first?.place.name ?? "")
                                            .foregroundColor(Color(hex: "#0E0F0C"))
                                            .font(appearance.fonts.locationMessageDescription)
                                    }
                                    
                                }
                            }.padding(.horizontal,15)
                        Spacer()
                    }
                } else {
                    searchPlacesView()
                }
            } // VSTACK
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarItems(leading: !isTextFieldFocused ? navBarLeadingBtn : nil, trailing: !isTextFieldFocused ? navBarTrailingBtn : nil)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text("Send Location")
                            .font(appearance.fonts.navigationBarTitle)
                            .foregroundColor(appearance.colorPalette.navigationBarTitle)
                    }
                }
            }
            .onAppear {
                // Settings
                locationManager.requestWhenInUseAuthorization()
                getPlaces()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                locationManager.requestWhenInUseAuthorization()
                getPlaces()
            }
            // Permission denied alert
            .alert(isPresented: $locationManager.permissionDenied) {
                Alert(
                    title: Text("Permission Denied"),
                    message: Text("Please Enable Permission in App Settings"),
                    dismissButton: .default(Text("Go to Settings")) {
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    }
                )
            }
            .onChange(of: searchText, { _, newValue in
                //searching places
                if searchText.count > 0{
                    if isTextFieldFocused  == false{
                        isTextFieldFocused = true
                    }
                }else{
                    isTextFieldFocused = false
                }
                let delay = 0.3
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    if newValue == searchText {
                        // Searching
                        fetchAutoCompletePredictions()
                    }
                }
            })
        }
    }
    
    
    //MARK: - SUBVIEW
    func nearByPlacesListView() -> some View{
        List{
            Section() {
                VStack(alignment: .leading){
                    Button {
                        longitude = mapViewModel.places.first?.place.coordinate.longitude
                        latitude = mapViewModel.places.first?.place.coordinate.latitude
                        placeId = mapViewModel.places.first?.place.placeID
                        placeName = mapViewModel.places.first?.place.name
                        address = mapViewModel.places.first?.place.formattedAddress
                        self.dismiss()
                    } label: {
                        HStack(alignment: .center,spacing: 15){
                            appearance.images.mapTarget
                                .resizable()
                                .frame(width: 24,height: 24)
                            VStack(alignment: .leading,spacing: 3){
                                Text("Send your current location")
                                    .font(appearance.fonts.messageListMessageText)
                                    .foregroundColor(appearance.colorPalette.messageListHeaderTitle)
                                Text("Accurate to 5 meters")
                                    .font(appearance.fonts.chatListUserMessage)
                                    .foregroundColor(appearance.colorPalette.chatListUserMessage)
                            }//:VSTACK
                        }//:HSTACK
                        .padding(.vertical,5)
                    }//:BUTTON
                }.listRowSeparator(.hidden)
            }//:SECTION
            
            Section(header: Text("NEARBY PLACES")) {
                ForEach(self.mapViewModel.places, id: \.place.placeID) { placeLikelihood in
                    PlaceRow(place: placeLikelihood.place)
                        .onTapGesture {
                            longitude = placeLikelihood.place.coordinate.longitude
                            latitude = placeLikelihood.place.coordinate.latitude
                            placeId = placeLikelihood.place.placeID
                            placeName = placeLikelihood.place.name
                            address = placeLikelihood.place.formattedAddress
                            self.dismiss()
                        }
                }//:FOREACH
            }
        }//:LIST
        .listRowSeparatorTint(Color.border)
        .listStyle(.insetGrouped)
        .background(Color.listBackground)
        .scrollContentBackground(.hidden)
    }
    
    func mapView(coordinate : CLLocationCoordinate2D?) -> some View{
        @State var camera: MapCameraPosition = .region(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: coordinate?.latitude ?? 0.0, longitude: coordinate?.longitude ?? 0.0),
                span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            )
        )
        return ZStack(alignment: .bottomTrailing){
            Map(position: $camera){
                Annotation("", coordinate: coordinate ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)) {
                    appearance.images.mapPinLogo
                        .resizable()
                        .frame(width: appearance.imagesSize.mapPinLogo.width,height: appearance.imagesSize.mapPinLogo.height)
                        .scaledToFit()
                }
            }
            appearance.images.mapDirection
                .resizable()
                .frame(width: 40, height: 40, alignment: .center)
                .padding(.trailing,15)
                .padding(.bottom,15)
        }
    }
    
    func searchPlacesView() -> some View{
        VStack{
            List(predictions, id: \.attributedFullText.string) { prediction in
                Text(prediction.attributedFullText.string)
                    .font(appearance.fonts.messageListMessageText)
                    .foregroundColor(appearance.colorPalette.messageListHeaderTitle)
                    .onTapGesture {
                        selectPlace(prediction)
                    }
            }//:LIST
            .listRowSeparator(.hidden).listStyle(.plain)
        }
    }
    //MARK: - CONFIGURE
    var navBarLeadingBtn : some View{
        Button(action: { dismiss() }) {
            appearance.images.backButton
                .resizable()
                .frame(width: appearance.imagesSize.backButton.width, height: appearance.imagesSize.backButton.height)
        }
    }
    
    var navBarTrailingBtn : some View{
        Button(action: { getPlaces() }) {
            appearance.images.refreshLocationLogo
                .resizable()
                .frame(width: 20, height: 20, alignment: .center)
            .imageScale(.large) }
    }
    
    //MARK: - APIS
    func getPlaces(){
        mapViewModel.currentPlacesList()
    }

    // MARK: - Location Search Methods
    
    /// Fetches autocomplete predictions from Google Places API
    /// This method is called when the user types in the search bar
    private func fetchAutoCompletePredictions() {
        let filter = GMSAutocompleteFilter()
        let placesClient = GMSPlacesClient.shared()
        
        // Use session token to optimize billing and ensure consistency
        placesClient.findAutocompletePredictions(
            fromQuery: searchText, 
            filter: filter, 
            sessionToken: sessionToken
        ) { predictions, error in
            if let error = error {
                ISMChatHelper.print("Error fetching autocomplete predictions: \(error.localizedDescription)")
                return
            }
            
            if let predictions = predictions {
                self.predictions = predictions
            }
        }
    }

    /// Handles the selection of a place from the autocomplete predictions
    /// - Parameter prediction: The selected GMSAutocompletePrediction object
    private func selectPlace(_ prediction: GMSAutocompletePrediction) {
        let placesClient = GMSPlacesClient.shared()
        let placeFields: GMSPlaceField = [.name, .coordinate, .placeID, .formattedAddress]
        
        placesClient.fetchPlace(
            fromPlaceID: prediction.placeID,
            placeFields: placeFields,
            sessionToken: sessionToken
        ) { place, error in
            if let error = error {
                ISMChatHelper.print("An error occurred: \(error.localizedDescription)")
                return
            }
            
            if let place = place {
                // Update location data and dismiss view
                self.updateLocationData(with: place)
                self.dismiss()
            }
        }
    }
    
    /// Updates the location data bindings with the selected place
    /// - Parameter place: The GMSPlace object containing location details
    private func updateLocationData(with place: GMSPlace) {
        self.longitude = place.coordinate.longitude
        self.latitude = place.coordinate.latitude
        self.placeId = place.placeID
        self.placeName = place.name
        self.address = place.formattedAddress
    }
}
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}



/// LocationManager class that handles location services and permissions
final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    @Published public var location: CLLocation?
    @Published public var permissionDenied = false
    @Published var authorizationStatus: CLAuthorizationStatus?
    
    override init() {
        super.init()
        locationManager.delegate = self
        requestWhenInUseAuthorization()
    }
    
    func requestWhenInUseAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    // Handle authorization status changes
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
        switch status {
        case .notDetermined:
            requestWhenInUseAuthorization() // Ask for permission again
        case .restricted, .denied:
            print("Location permission denied")
            permissionDenied.toggle()
        case .authorizedWhenInUse, .authorizedAlways:
            print("Location permission granted")
            locationManager.requestLocation()
            locationManager.startUpdatingLocation()
        @unknown default:
            break
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else{
            return
        }
        self.location = location
        manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error.localizedDescription)")
    }

}

