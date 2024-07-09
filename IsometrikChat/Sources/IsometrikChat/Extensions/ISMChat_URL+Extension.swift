//
//  URL+Extension.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 13/03/23.
//

import Foundation
import SwiftUI

extension URL {
    public func fileSize() -> String {
        do{
            let resource = try self.resourceValues(forKeys: [.fileSizeKey])
            let filesize = resource.fileSize ?? 0
            return "\(filesize)"
        }catch{
            ISMChat_Helper.print("error")
        }
        return "0"
    }
}

extension View {
    public func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}
public struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    public func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension URL {
    public func valueOf(_ queryParameterName: String) -> String? {
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == queryParameterName })?.value
    }
}
