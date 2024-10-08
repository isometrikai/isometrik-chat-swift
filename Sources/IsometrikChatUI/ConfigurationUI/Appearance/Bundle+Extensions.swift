//
//  File.swift
//  
//
//  Created by Ajay Thakur on 12/06/24.
//

import Foundation

private class BundleIdentifyingClass {}

extension Bundle {
    static var isometrikChat: Bundle {
        // We're using `resource_bundles` to export our resources in the podspec file
        // (See https://guides.cocoapods.org/syntax/podspec.html#resource_bundles)
        // since we need to support building pod as a static library.
        // This attribute causes cocoapods to build a resource bundle and put all our resources inside, during `pod install`
        // But this bundle exists only for cocoapods builds, and for other methods (Carthage, git submodule) we directly export
        // assets.
        // So we need this compiler check to decide which bundle to use.
        #if COCOAPODS
        return Bundle(for: BundleIdentifyingClass.self)
            .url(forResource: "Resources", withExtension: "bundle")
            .flatMap(Bundle.init(url:))!
        #elseif SWIFT_PACKAGE
        return Bundle.module
        #elseif STATIC_LIBRARY
        return Bundle.main
            .url(forResource: "Resources", withExtension: "bundle")
            .flatMap(Bundle.init(url:))!
        #else
        return Bundle(for: BundleIdentifyingClass.self)
        #endif
    }
}
