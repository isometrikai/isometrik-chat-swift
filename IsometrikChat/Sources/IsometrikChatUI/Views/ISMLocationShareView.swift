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

struct ISMLocationShareView: View {
    
    //MARK:  - PROPERTIES
    @Environment(\.dismiss) var dismiss
    
    @StateObject var mapViewModel = MapViewModel()
    @State var locationManager = CLLocationManager()
    @State private var showSheet = true
    @Binding var longitude : Double?
    @Binding var latitude : Double?
    @Binding var placeId : String?
    @Binding var placeName : String?
    @Binding var address : String?
    @FocusState private var isTextFieldFocused: Bool
    @State private var searchText = ""
    @State private var predictions: [GMSAutocompletePrediction] = []
    @State private var selectedPlaceAfterSerch: GMSPlace?
    @State var themeFonts = ISMChatSdk.getInstance().getAppAppearance().appearance.fonts
    @State var themeColor = ISMChatSdk.getInstance().getAppAppearance().appearance.colorPalette
    @State var themeImage = ISMChatSdk.getInstance().getAppAppearance().appearance.images
    
    //MARK:  - LIFECYCLE
    var body: some View {
        ZStack{
            VStack(spacing: 0) {
                HStack {
                    HStack {
                        themeImage.searchMagnifingGlass
                            .foregroundStyle(.gray.opacity(0.5))
                        TextField("Search or enter an address", text: $searchText)
                            .focused($isTextFieldFocused)
                            .font(themeFonts.messageList_MessageText)
                    }//:HSTACK
                    .padding(5)
                    .background(Color(.systemFill).opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    if isTextFieldFocused {
                        Button("Cancel", action: {
                            hideKeyboard()
                            searchText = ""
                            withAnimation {
                                isTextFieldFocused = false
                            }
                        })//:BUTTON
                        .transition(.move(edge: .trailing))
                    }
                }//:HSTACK
                .padding()
                if isTextFieldFocused == false{
                    mapView(coordinate: CLLocationCoordinate2D(latitude: mapViewModel.latitude, longitude: mapViewModel.longitude))
                        .frame(height: 300)
                    nearByPlacesListView()
                }else{
                    searchPlacesView()
                }
            }//:VSTACK
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text("Send Location")
                            .font(themeFonts.navigationBar_Title)
                            .foregroundColor(themeColor.navigationBar_Title)
                    }
                }
            }
            .navigationBarItems(leading: isTextFieldFocused == false ? navBarLeadingBtn : nil,trailing:  isTextFieldFocused == false ? navBarTrailingBtn : nil)
            .onAppear(){
                //setting
                locationManager.delegate = mapViewModel
                locationManager.requestWhenInUseAuthorization()
                getPlaces()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                locationManager.delegate = mapViewModel
                locationManager.requestWhenInUseAuthorization()
                getPlaces()
            }
            //permission denied alert
            .alert(isPresented: $mapViewModel.permissionDenied) {
                Alert(title: Text("Permission Denied"),message: Text("Please Enable Permission in App Settings"),dismissButton: .default(Text("Go to Settings"),action: {
                    //redirecting user to app settings
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                }))
            }
            .onChange(of: searchText) { newValue in
                //searching places
                let delay = 0.3
                DispatchQueue.main.asyncAfter(deadline: .now() + delay){
                    if newValue == searchText{
                        //searching
                        fetchAutoCompletePredictions()
                    }
                }
            }
        }//:ZSTACK
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
                            themeImage.mapTarget
                                .resizable()
                                .frame(width: 24,height: 24)
                            VStack(alignment: .leading,spacing: 3){
                                Text("Send your current location")
                                    .font(themeFonts.messageList_MessageText)
                                    .foregroundColor(themeColor.messageList_MessageText)
                                Text("Accurate to 5 meters")
                                    .font(themeFonts.chatList_UserMessage)
                                    .foregroundColor(themeColor.chatList_UserMessage)
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
        @State var camera : MapCameraPosition = .automatic
        return Map(position: $camera){
            Annotation("", coordinate: coordinate ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)) {
                themeImage.mapPinLogo
                    .resizable()
                    .frame(width: 30, height: 30, alignment: .center)
            }
        }
    }
    
    func searchPlacesView() -> some View{
        VStack{
            List(predictions, id: \.attributedFullText.string) { prediction in
                Text(prediction.attributedFullText.string)
                    .font(themeFonts.messageList_MessageText)
                    .foregroundColor(themeColor.messageList_MessageText)
                    .onTapGesture {
                        selectPlace(prediction)
                    }
            }//:LIST
            .listRowSeparator(.hidden).listStyle(.plain)
        }
    }
    //MARK: - CONFIGURE
    var navBarLeadingBtn : some View{
        Button(action : {}) {
            HStack{
                Button(action: { dismiss() }) {
                    themeImage.backButton
                        .resizable()
                        .frame(width: 18, height: 18)
                }
            }
        }
    }
    
    var navBarTrailingBtn : some View{
        HStack{
            Button(action: { getPlaces() }) {
                themeImage.scrollToBottomArrow
                    .foregroundColor(themeColor.userProfile_editText)
                .imageScale(.large) }
        }
    }
    
    //MARK: - APIS
    func getPlaces(){
        mapViewModel.currentPlacesList()
    }
    private func fetchAutoCompletePredictions() {
        let filter = GMSAutocompleteFilter()
        let placesClient = GMSPlacesClient.shared()
        placesClient.findAutocompletePredictions(fromQuery: searchText, filter: filter, sessionToken: nil) { predictions, error in
            if let error = error {
                ISMChat_Helper.print("Error fetching autocomplete predictions: \(error.localizedDescription)")
                return
            }
            
            if let predictions = predictions {
                self.predictions = predictions
            }
        }
    }
    private func selectPlace(_ prediction: GMSAutocompletePrediction) {
        let placesClient = GMSPlacesClient.shared()
        let fields: GMSPlaceField = GMSPlaceField(rawValue:UInt64(UInt(UInt64(UInt(GMSPlaceField.name.rawValue) |
                                                                              UInt(GMSPlaceField.placeID.rawValue) |
                                                                              UInt(GMSPlaceField.coordinate.rawValue) |
                                                                              UInt(GMSPlaceField.formattedAddress.rawValue)))))
        placesClient.fetchPlace(fromPlaceID: prediction.placeID, placeFields: fields, sessionToken: nil, callback: { place, error in
            if let error = error {
                ISMChat_Helper.print("An error occurred: \(error.localizedDescription)")
                return
            }
            
            if let place = place {
                longitude = place.coordinate.longitude
                latitude = place.coordinate.latitude
                placeId = place.placeID
                placeName = place.name
                address = place.formattedAddress
                self.dismiss()
            }
        })
    }
}
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
