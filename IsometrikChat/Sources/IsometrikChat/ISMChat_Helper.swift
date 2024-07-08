//
//  Helper.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 03/03/23.
//

import Foundation
import UIKit
import SwiftUI
import AVFoundation
import PDFKit
import CoreLocation
import CoreLocationUI
import FirebaseMessaging

class ISMChat_Helper: NSObject {
    
    //MARK: - Convert to Readable Test
//    class func fromBase64(word : String) -> String{
//        let base64decoded = Data(base64Encoded: word)
//        if let base64decoded = base64decoded{
//            let decodedString = String(data: base64decoded, encoding: .utf8) ?? word
//            return decodedString
//        }else{
//            return word
//        }
//    }
    
    //MARK: - Convert to Nonreadable Text
//    class func toBase64(word : String) -> String{
//        let base64encoded = word.data(using: String.Encoding.utf8)!.base64EncodedString()
//        return base64encoded
//    }
    
    //MARK: - Convert Timestamp to Date String
    class func timeStamptoDateString(format : String,timeStamp : Double) -> String{
        let unixTimeStamp: Double = Double(timeStamp) / 1000.0
        let exactDate = NSDate.init(timeIntervalSince1970: unixTimeStamp)
        let dateFormatt = DateFormatter()
        dateFormatt.dateFormat = format
        return dateFormatt.string(from: exactDate as Date)
    }
    
    //MARK: - Check if String is valid email
    class func isValidEmail(_ email: String) -> Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: email)
    }
    
    //MARK: - Check if String is valid phone number
    class func isValidPhone(phone: String) -> Bool {
        let phoneRegex = "^[7-9][0-9]{9}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phoneTest.evaluate(with: phone)
    }
    
    //MARK: - Check message delivery status
    class func checkMessageDeliveryType(message : MessagesDB,isGroup: Bool,memberCount:Int = 0) -> ISMChat_MessageStatus{
        if isGroup {
            if (memberCount - 1) == message.readBy.count {
                return .BlueTick
            }else if (memberCount - 1) == message.deliveredTo.count {
                return .DoubleTick
            }
            if message.msgSyncStatus == ISMChat_SyncStatus.Local.txt {
                return .Clock
            }
            return .SingleTick
        }else {
            if message.deliveredToAll == true && message.readByAll == true{
                return .BlueTick
            }else if message.deliveredToAll == true && message.readByAll == false{
                return .DoubleTick
            }else{
                if message.msgSyncStatus == ISMChat_SyncStatus.Local.txt {
                    return .Clock
                }
                return .SingleTick
            }
        }
    }
    
    //MARK: - CHECK IMAGE OR Video
    
    class func checkMediaType(media : URL) -> ISMChat_MessageType{
        if media.lastPathComponent.contains(".mov") || media.lastPathComponent.contains(".mp4"){
            return .video
        }else{
            return .photo
        }
    }
    
    class func checkMediaCustomType(media : URL) -> String{
        if media.lastPathComponent.contains(".mov") || media.lastPathComponent.contains(".mp4"){
            return ISMChat_MediaType.Video.value
        }else{
            return ISMChat_MediaType.Image.value
        }
    }
    
    class func isVideo(media : URL) -> Bool{
        if media.lastPathComponent.contains(".mov") || media.lastPathComponent.contains(".mp4"){
            return true
        }else{
            return false
        }
    }
    //MARK: - Custom print(Make the logger which will print the logs only in debugging mode and enable and disable logs.)
    class func print(_ object : Any){
        let showPrint : Bool = true
       #if DEBUG
        if showPrint == true{
            Swift.print(object)
        }
       #endif
    }
    
    class func print(_ object : Any...){
        let showPrint : Bool = true
       #if DEBUG
        if showPrint == true{
            for item in object{
                Swift.print(item)
            }
        }
       #endif
    }
    
    //MARK: - GET Message Type
    class func getMessageType(message : MessagesDB) -> ISMChat_MessageType{
        if message.customType == ISMChat_MediaType.Video.value{
            return .video
        }else if message.customType == ISMChat_MediaType.Voice.value{
            return .audio
        }else if message.customType == ISMChat_MediaType.File.value{
            return .document
        }else if message.customType == ISMChat_MediaType.Image.value{
            return .photo
        }else if message.customType == ISMChat_MediaType.Location.value{
            return .location
        }else if message.customType == ISMChat_MediaType.Contact.value{
            return .contact
        }else if message.customType == ISMChat_MediaType.VideoCall.value{
            return .VideoCall
        }else if message.customType == ISMChat_MediaType.AudioCall.value{
            return .AudioCall
        }else if message.customType == ISMChat_MediaType.gif.value{
            return .gif
        }else if message.customType == ISMChat_MediaType.sticker.value{
            return .sticker
        }
        else{
            if message.action == ISMChat_ActionType.userBlock.value || message.action == ISMChat_ActionType.userBlockConversation.value{
                return .blockUser
            }else if message.action == ISMChat_ActionType.userUnblock.value || message.action == ISMChat_ActionType.userUnblockConversation.value{
                return .unblockUser
            }else if message.action == ISMChat_ActionType.conversationTitleUpdated.value{
                return .conversationTitleUpdate
            }else if message.action == ISMChat_ActionType.conversationImageUpdated.value{
                return .conversationImageUpdated
            }else if message.action == ISMChat_ActionType.conversationCreated.value{
                return .conversationCreated
            }else if message.action == ISMChat_ActionType.membersAdd.value{
                return .membersAdd
            }else if message.action == ISMChat_ActionType.memberLeave.value{
                return .memberLeave
            }else if message.action == ISMChat_ActionType.membersRemove.value{
                return .membersRemove
            }else if message.action == ISMChat_ActionType.addAdmin.value{
                return .addAdmin
            }else if message.action == ISMChat_ActionType.removeAdmin.value{
                return .removeAdmin
            }else if message.action == ISMChat_ActionType.conversationSettingsUpdated.value{
                return .conversationSettingsUpdated
            }
            return .text
        }
    }
    
    //MARK: - GET EMOJI
    
    class func getEmoji(valueString : String) -> String{
        for case let emojiReaction in ISMChat_EmojiReaction.allCases {
            if emojiReaction.info.valueString == valueString {
                return emojiReaction.info.emoji
            }
        }
        return ""
    }
    
    //MARK: - Convert sec to min and hr
    func covertSecToMinAndHour(seconds : Int) -> String{
        let (_,m,s) = (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
        let sec : String = s < 10 ? "0\(s)" : "\(s)"
        return "\(m):\(sec)"
    }
    
    //MARK: - GET File Date
    func getFileDate(for file: URL) -> Date {
        if let attributes = try? FileManager.default.attributesOfItem(atPath: file.path) as [FileAttributeKey: Any],
            let creationDate = attributes[FileAttributeKey.creationDate] as? Date {
            return creationDate
        } else {
            return Date()
        }
    }
    func returnLatitude(string : String) -> String{
        let newURL = URL(string: string)!
        let coordinate = newURL.valueOf("query")
        let values = coordinate?.split(separator: ",")
        let latitude = String(values?[0] ?? "")
        return (latitude)
    }
    func convertLatitudeStringToDouble(latitudeString: String) -> CLLocationDegrees? {
        if let latitude = Double(latitudeString) {
            return CLLocationDegrees(latitude)
        } else {
            return nil
        }
    }
    
    func returnLongitude(string : String) -> String{
        let newURL = URL(string: string)!
        let coordinate = newURL.valueOf("query")
        let values = coordinate?.split(separator: ",")
        let longitude = String(values?[1] ?? "")
        return longitude
    }
    
    func convertLongituteStringToDouble(latitudeString: String) -> CLLocationDegrees? {
        if let latitude = Double(latitudeString) {
            return CLLocationDegrees(latitude)
        } else {
            return nil
        }
    }
    
    
    //MARK: - CONVERT VIDEOURL TO IMAGE THUMBNAIL
    
    class func generateThumbnailImageURL(from videoURL: URL, completion: @escaping (URL?) -> Void) {
        let asset = AVAsset(url: videoURL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        let time = CMTimeMake(value: 1, timescale: 2) // You can change this time to get a different frame from the video
        
        do {
            let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            let uiImage = UIImage(cgImage: cgImage)
            
            // You can save the thumbnail image to the document directory or any other location
            if let data = uiImage.jpegData(compressionQuality: 0.8) {
                let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let imageURL = documentDirectory.appendingPathComponent("thumbnail.jpg")
                
                do {
                    try data.write(to: imageURL)
                    completion(imageURL)
                } catch {
                    ISMChat_Helper.print("Error saving thumbnail image: \(error)")
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        } catch {
            ISMChat_Helper.print("Error generating thumbnail image: \(error)")
            completion(nil)
        }
    }
    
    //MARK: - COMPRESS IMAGE
    class func compressImage(image: URL) -> UIImage? {
        let fileURL = image
        do {
            let imageData = try Data(contentsOf: fileURL)
            return UIImage(data: imageData,scale: 0.1)
        } catch {
            print("Error loading image : \(error)")
        }
        return nil
    }
    
    
    //MARK: - GENERATE THUMBMNAIL
    
//    class func generateImage(name: String,backgroundColor : UIColor) -> Image {
//        if let image = generateImageWithInitials(name, backgroundColor: backgroundColor){
//            return Image(uiImage: image)
//        }else{
//            return Image("")
//        }
//    }
//    
//    class  func generateImageWithInitials(_ initials: String,backgroundColor : UIColor) -> UIImage? {
//        let frame = CGRect(x: 0, y: 0, width: 50, height: 50)
//        let nameLabel = UILabel(frame: frame)
//        nameLabel.textAlignment = .center
//        nameLabel.backgroundColor = .lightGray
//        nameLabel.textColor = .white
//        nameLabel.font = UIFont.boldSystemFont(ofSize: 20)
//        nameLabel.text = "\(initials.uppercased())"
//        UIGraphicsBeginImageContext(frame.size)
//        if let currentContext = UIGraphicsGetCurrentContext() {
//            nameLabel.layer.render(in: currentContext)
//            let nameImage = UIGraphicsGetImageFromCurrentImageContext()
//            return nameImage
//        }
//        return nil
//    }
    
    func pdfThumbnail(url: URL, width: CGFloat = 240) -> UIImage? {
      guard let data = try? Data(contentsOf: url),
      let page = PDFDocument(data: data)?.page(at: 0) else {
        return nil
      }

      let pageSize = page.bounds(for: .mediaBox)
      let pdfScale = width / pageSize.width

      // Apply if you're displaying the thumbnail on screen
      let scale = UIScreen.main.scale * pdfScale
      let screenSize = CGSize(width: pageSize.width * scale,
                              height: pageSize.height * scale)

      return page.thumbnail(of: screenSize, for: .mediaBox)
    }
    
    class  func getAddressFromLatLon(Latitude: String,Longitude: String, completion:@escaping(String?)->()){
        var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
        let lat: Double = Double("\(Latitude)")!
        let lon: Double = Double("\(Longitude)")!
        let ceo: CLGeocoder = CLGeocoder()
        center.latitude = lat
        center.longitude = lon
        var addressString : String = ""
        let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
        ceo.reverseGeocodeLocation(loc, completionHandler:
                                    {(placemarks, error) in
            if (error != nil){
                ISMChat_Helper.print("reverse geodcode fail: \(error!.localizedDescription)")
            }
            if let pm = placemarks{
                
                if pm.count > 0 {
                    let pm = placemarks![0]
                    if pm.subLocality != nil {
                        addressString = addressString + pm.subLocality! + ", "
                    }
                    if pm.thoroughfare != nil {
                        addressString = addressString + pm.thoroughfare! + ", "
                    }
                    if pm.locality != nil {
                        addressString = addressString + pm.locality! + ", "
                    }
                    if pm.country != nil {
                        addressString = addressString + pm.country! + ", "
                    }
                    if pm.postalCode != nil {
                        addressString = addressString + pm.postalCode! + " "
                    }
                    completion(addressString)
                }
            }
        })
    }
    
    class  func getFileNameFromURL(url: URL) -> String {
        let filename = url.lastPathComponent
        let components = filename.components(separatedBy: "_")
        if let lastComponent = components.last {
            return lastComponent
        }else{
            return url.lastPathComponent
        }
    }
    
    class func parseJSONString(jsonString: String) -> (count: Int, firstDisplayName: String?) {
        if let data = jsonString.data(using: .utf8) {
            do {
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                    // Count of data
                    let count = jsonArray.count
                    
                    // Get the first displayName
                    let firstDisplayName = jsonArray.first?["displayName"] as? String
                    
                    return (count, firstDisplayName)
                }
            } catch {
                print("Error parsing JSON: \(error)")
            }
        }
        
        return (0, nil) // Return default values if parsing fails
    }
    
    class  func pdfThumbnail(url: URL, width: CGFloat = 240, _ completion: @escaping ((UIImage?) -> Void)) {
        DispatchQueue.global(qos: .userInitiated).async {
            
            guard let data = try? Data(contentsOf: url),
            let page = PDFDocument(data: data)?.page(at: 0) else {
                DispatchQueue.main.async {
                    completion(UIImage())
                }
                return
            }

            let pageSize = page.bounds(for: .mediaBox)
            let pdfScale = width / pageSize.width

            // Apply if you're displaying the thumbnail on screen
            let scale = UIScreen.main.scale * pdfScale
            let screenSize = CGSize(width: pageSize.width * scale,
                                    height: pageSize.height * scale)

            completion(page.thumbnail(of: screenSize, for: .mediaBox) )
            
        }
    }
    
    class func getExtensionFromURL(url: URL) -> String? {
        let filename = url.lastPathComponent
        let components = filename.components(separatedBy: "_")
        guard let lastComponent = components.last else { return "" }
        return NSURL(fileURLWithPath: lastComponent).pathExtension
    }
    
    class func subscribeFCM(){
        if let userId = ChatKeychain.shared.userId{
            Messaging.messaging().subscribe(toTopic: "chat-\(userId)") { (error) in
                if error != nil {
                    print("errror fcm topic ", error as Any)
                }
            }
        }
    }
    
//    unsubscribe all fcm topics
    class func unSubscribeFCM(){
        if let userId = ChatKeychain.shared.userId{
            Messaging.messaging().unsubscribe(fromTopic: "chat-\(userId)")
        }
    }
    
    class func getThumbnailImage(url : String) -> UIImage? {
        
        guard let videoURL = URL(string: url) else {
            return nil
        }

        var thumbnailImage: UIImage?
        let asset = AVAsset(url: videoURL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)

        // Set precise time-based extraction
        imageGenerator.requestedTimeToleranceBefore = CMTime.zero
        imageGenerator.requestedTimeToleranceAfter = CMTime.zero

        // Set maximumSize for improved quality
        imageGenerator.maximumSize = CGSize(width: 640, height: 480) // Adjust the size as needed

        // Choose a specific time for the thumbnail (e.g., 0 seconds)
        let thumbnailTime = CMTime(seconds: 0, preferredTimescale: 60)

        do {
            let cgImage = try imageGenerator.copyCGImage(at: thumbnailTime, actualTime: nil)
            thumbnailImage = UIImage(cgImage: cgImage)
        } catch {
            print("Error generating thumbnail: \(error)")
        }

        return thumbnailImage
    }
    
    class func createImageURL() -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent("\(UUID()).jpg")
        return fileURL
    }
    
    class func sentAtTimeForLocalDB() -> Double {
        // Create a DateFormatter instance
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        // Set the desired date format
        dateFormatter.dateFormat = "h:mm a"
        let currentTime = Date()
        let timeInSeconds = currentTime.timeIntervalSince1970
        return timeInSeconds
    }
}

extension ISMChat_Helper{
    //MARK: - SECTION HEADER
    
    class func sectionHeader(firstMessage message : MessagesDB,color : Color,font : Font) -> some View{
        ZStack{
            let sentAt = message.sentAt
            let date = NSDate().descriptiveStringLastSeen(time: sentAt,isSectionHeader: true)
            Text(date)
                .foregroundColor(color)
                .font(font)
                .padding(.vertical,5)
            
        }//:ZStack
        .padding(.vertical,5)
        .frame(maxWidth : .infinity)
    }
}
