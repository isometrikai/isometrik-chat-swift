// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "IsometrikChat",
    defaultLocalization: "en",
    platforms: [.iOS(.v17),],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "IsometrikChat",
            targets: ["IsometrikChat"]),
        .library(
            name: "IsometrikChatUI",
            targets: ["IsometrikChatUI"])
    ],
    dependencies: [
        .package(url: "https://github.com/googlemaps/ios-places-sdk", from: "9.0.0"),
        .package(url: "https://github.com/googlemaps/ios-maps-sdk", from: "9.0.0"),
        .package(url: "https://github.com/guoyingtao/Mantis", from: "2.22.0"),
        .package(url: "https://github.com/Yummypets/YPImagePicker", from: "5.2.2"),
        .package(url: "https://github.com/Alamofire/Alamofire", from: "5.8.1"),
        .package(url: "https://github.com/isometrikai/isometrik-call-ios",branch: "main"),
        .package(url: "https://github.com/SDWebImage/SDWebImageSwiftUI.git", from: "3.1.1"),
        .package(url: "https://github.com/realm/realm-swift", from: "10.52.3"),
        .package(url: "https://github.com/exyte/MediaPicker",branch: "2.2.3"),
        .package(url: "https://github.com/Giphy/giphy-ios-sdk", exact: "2.2.12"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "IsometrikChat",
            dependencies: [
                .product(name: "GooglePlaces", package: "ios-places-sdk"),
                .product(name: "GoogleMaps", package: "ios-maps-sdk"),
                .product(name: "Mantis", package: "mantis"),
                .product(name: "YPImagePicker", package: "ypimagepicker"),
                .product(name: "Alamofire", package: "alamofire"),
                .product(name: "ISMSwiftCall", package: "isometrik-call-ios"),
                .product(name: "SDWebImageSwiftUI", package: "sdwebimageswiftui"),
                .product(name: "RealmSwift", package: "realm-swift"),
                .product(name: "ExyteMediaPicker", package: "MediaPicker"),
                .product(name: "GiphyUISDK", package: "giphy-ios-sdk"),
            ]),
        .target(
            name: "IsometrikChatUI",
            dependencies: [
                "IsometrikChat",
                .product(name: "GooglePlaces", package: "ios-places-sdk"),
                .product(name: "GoogleMaps", package: "ios-maps-sdk"),
                .product(name: "Mantis", package: "mantis"),
                .product(name: "YPImagePicker", package: "ypimagepicker"),
                .product(name: "Alamofire", package: "alamofire"),
                .product(name: "ISMSwiftCall", package: "isometrik-call-ios"),
                .product(name: "SDWebImageSwiftUI", package: "sdwebimageswiftui"),
                .product(name: "RealmSwift", package: "realm-swift"),
                .product(name: "ExyteMediaPicker", package: "MediaPicker"),
                .product(name: "GiphyUISDK", package: "giphy-ios-sdk"),
            ],resources: [
                .process("Resources/Assets.xcassets"),
                .process("Resources/en.lproj"),
                .process("Resources/fr.lproj")
            ])
        
    ]
)
