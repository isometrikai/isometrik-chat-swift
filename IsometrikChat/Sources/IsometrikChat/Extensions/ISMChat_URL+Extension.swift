//
//  URL+Extension.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 13/03/23.
//

import Foundation
import SwiftUI

extension URL {
    func fileSize() -> String {
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
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}
struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension URL {
    func valueOf(_ queryParameterName: String) -> String? {
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == queryParameterName })?.value
    }
}
