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
//import FirebaseMessaging
import PhotosUI

public class ISMChatHelper: NSObject {
    
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
    public class func timeStamptoDateString(format : String,timeStamp : Double) -> String{
        let unixTimeStamp: Double = Double(timeStamp) / 1000.0
        let exactDate = NSDate.init(timeIntervalSince1970: unixTimeStamp)
        let dateFormatt = DateFormatter()
        dateFormatt.dateFormat = format
        return dateFormatt.string(from: exactDate as Date)
    }
    
    //MARK: - Check if String is valid email
    public class func isValidEmail(_ email: String) -> Bool {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: trimmedEmail)
    }
    
    //MARK: - Check if String is valid phone number
    public class func isValidPhone(phone: String) -> Bool {
        let trimmedPhone = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        let phoneRegex = "^[7-9][0-9]{9}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phoneTest.evaluate(with: trimmedPhone)
    }
    
    //MARK: - Check message delivery status
    public class func checkMessageDeliveryType(message : MessagesDB,isGroup: Bool,memberCount:Int = 0,isOneToOneGroup : Bool) -> ISMChatMessageStatus{
        if isOneToOneGroup{
            //one to one group is same as single chat
            if message.deliveredToAll == true && message.readByAll == true{
                return .BlueTick
            }else if message.deliveredToAll == true && message.readByAll == false{
                return .DoubleTick
            }else{
                if message.msgSyncStatus == ISMChatSyncStatus.Local.txt {
                    return .Clock
                }
                return .SingleTick
            }
        }else{
            if isGroup {
                if (memberCount - 1) == message.readBy.count {
                    return .BlueTick
                }else if (memberCount - 1) == message.deliveredTo.count {
                    return .DoubleTick
                }
                if message.msgSyncStatus == ISMChatSyncStatus.Local.txt {
                    return .Clock
                }
                return .SingleTick
            }else {
                if message.deliveredToAll == true && message.readByAll == true{
                    return .BlueTick
                }else if message.deliveredToAll == true && message.readByAll == false{
                    return .DoubleTick
                }else{
                    if message.msgSyncStatus == ISMChatSyncStatus.Local.txt {
                        return .Clock
                    }
                    return .SingleTick
                }
            }
        }
    }
    
    //MARK: - CHECK IMAGE OR Video
    
    public class func checkMediaType(media: URL) -> ISMChatMessageType {
        let videoExtensions: Set<String> = ["mov", "mp4"]
        
        // Extract the file extension and compare case-insensitively
        let fileExtension = media.pathExtension.lowercased()
        if videoExtensions.contains(fileExtension) {
            return .video
        } else {
            return .photo
        }
    }

    
    public class func checkMediaCustomType(media : URL) -> String{
        let videoExtensions: Set<String> = ["mov", "mp4"]
        
        // Extract the file extension and compare case-insensitively
        let fileExtension = media.pathExtension.lowercased()
        if videoExtensions.contains(fileExtension) {
            return ISMChatMediaType.Video.value
        } else {
            return ISMChatMediaType.Image.value
        }
    }
    
    public class func isVideoString(media : String) -> Bool{
        if media.lowercased().contains(".mov") || media.lowercased().contains(".mp4"){
            return true
        }else{
            return false
        }
    }
    
    public class func isVideo(media : URL) -> Bool{
        let videoExtensions: Set<String> = ["mov", "mp4"]
        
        // Extract the file extension and compare case-insensitively
        let fileExtension = media.lastPathComponent.lowercased()
        if videoExtensions.contains(fileExtension) {
            return true
        } else {
            return false
        }
    }
    //MARK: - Custom print(Make the logger which will print the logs only in debugging mode and enable and disable logs.)
    public class func print(_ object : Any){
        let showPrint : Bool = true
       #if DEBUG
        if showPrint == true{
            Swift.print(object)
        }
       #endif
    }
    
    public class func print(_ object : Any...){
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
    public class func getMessageType(message : MessagesDB) -> ISMChatMessageType{
        if message.customType == ISMChatMediaType.Video.value{
            return .video
        }else if message.customType == ISMChatMediaType.Voice.value{
            return .audio
        }else if message.customType == ISMChatMediaType.File.value{
            return .document
        }else if message.customType == ISMChatMediaType.Image.value{
            return .photo
        }else if message.customType == ISMChatMediaType.Location.value{
            return .location
        }else if message.customType == ISMChatMediaType.Contact.value{
            return .contact
        }else if message.customType == ISMChatMediaType.VideoCall.value{
            return .VideoCall
        }else if message.customType == ISMChatMediaType.AudioCall.value{
            return .AudioCall
        }else if message.customType == ISMChatMediaType.GroupCall.value{
            return .GroupCall
        }else if message.customType == ISMChatMediaType.gif.value{
            return .gif
        }else if message.customType == ISMChatMediaType.sticker.value{
            return .sticker
        }else if message.customType == ISMChatMediaType.Post.value{
            return .post
        }else if message.customType == ISMChatMediaType.Product.value{
            return .Product
        }else if message.customType == ISMChatMediaType.ProductLink.value{
            return .ProductLink
        }else if message.customType == ISMChatMediaType.SocialLink.value{
            return .SocialLink
        }else if message.customType == ISMChatMediaType.CollectionLink.value{
            return .CollectionLink
        }else if message.customType == ISMChatMediaType.PaymentRequest.value{
            return .paymentRequest
        }else if message.customType == ISMChatMediaType.DineInInvite.value{
            return .dineInInvite
        }else if message.customType == ISMChatMediaType.DineInStatus.value{
            return .dineInInviteStatus
        }else if message.customType == ISMChatMediaType.ProfileShare.value{
            return .ProfileShare
        }else if message.customType == ISMChatMediaType.OfferSent.value{
            return .OfferSent
        }else if message.customType == ISMChatMediaType.CounterOffer.value{
            return .CounterOffer
        }else if message.customType == ISMChatMediaType.EditOffer.value{
            return .EditOffer
        }else if message.customType == ISMChatMediaType.AcceptOrder.value{
            return .AcceptOrder
        }else if message.customType == ISMChatMediaType.CancelDeal.value{
            return .CancelDeal
        }else if message.customType == ISMChatMediaType.CancelOffer.value{
            return .CancelOffer
        }else if message.customType == ISMChatMediaType.BuyDirectRequest.value{
            return .BuyDirectRequest
        }else if message.customType == ISMChatMediaType.AcceptBusyDirectRequest.value{
            return .AcceptBusyDirectRequest
        }else if message.customType == ISMChatMediaType.CancelBuyDirectRequest.value{
            return .CancelBuyDirectRequest
        }else if message.customType == ISMChatMediaType.RejectBuyDirectRequest.value{
            return .RejectBuyDirectRequest
        }else if message.customType == ISMChatMediaType.PaymentEscrowed.value{
            return .PaymentEscrowed
        }else if message.customType == ISMChatMediaType.DealComplete.value{
            return .DealComplete
        }else if message.customType == ISMChatMediaType.cheaper.value{
            return .cheaper
        }else if message.customType == ISMChatMediaType.cheaperCancelOffer.value{
            return .cheaperCancelOffer
        }else if message.customType == ISMChatMediaType.cheaperAcceptOffer.value{
            return .cheaperAcceptOffer
        }else if message.customType == ISMChatMediaType.cheaperCounterOffer.value{
            return .cheaperCounterOffer
        }
        else{
            if message.action == ISMChatActionType.userBlock.value || message.action == ISMChatActionType.userBlockConversation.value{
                return .blockUser
            }else if message.action == ISMChatActionType.userUnblock.value || message.action == ISMChatActionType.userUnblockConversation.value{
                return .unblockUser
            }else if message.action == ISMChatActionType.conversationTitleUpdated.value{
                return .conversationTitleUpdate
            }else if message.action == ISMChatActionType.conversationImageUpdated.value{
                return .conversationImageUpdated
            }else if message.action == ISMChatActionType.conversationCreated.value{
                return .conversationCreated
            }else if message.action == ISMChatActionType.membersAdd.value{
                return .membersAdd
            }else if message.action == ISMChatActionType.memberLeave.value{
                return .memberLeave
            }else if message.action == ISMChatActionType.membersRemove.value{
                return .membersRemove
            }else if message.action == ISMChatActionType.addAdmin.value{
                return .addAdmin
            }else if message.action == ISMChatActionType.removeAdmin.value{
                return .removeAdmin
            }else if message.action == ISMChatActionType.conversationSettingsUpdated.value{
                return .conversationSettingsUpdated
            }
            return .text
        }
    }
    
    public class func getPaymentStatus(myUserId: String,opponentId : String, metaData: MetaDataDB?, sentAt: Double) -> ISMChatPaymentRequestStatus {
        // Retrieve the member from paymentRequestedMembers matching myUserId
        guard let paymentRequestedMembers = metaData?.paymentRequestedMembers else {
            return .ActiveRequest // Default status if no members are found
        }
        // Find the specific member with myUserId
        guard let member = paymentRequestedMembers.first(where: { $0.userId == myUserId }) else {
            return .ActiveRequest // Default status if no matching member is found
        }
        
        let opponentMember = paymentRequestedMembers.first(where: { $0.userId == opponentId })
        
        if member.status == 4 || opponentMember?.status == 4 {
            return .Cancelled
        }
        
        if member.status == 2 || opponentMember?.status == 2 {
            return .Rejected
        }

        // Check the status of the matched member
        if let status = member.status {
            if status == 1{
                return .Accepted
            }else if status == 2{
                return .Rejected
            }else if status == 3{
                // Check if any other user's status is 1 (Accepted)
                    if paymentRequestedMembers.contains(where: { $0.userId != myUserId && $0.status == 1 }) {
                        return .PayedByOther
                    }else{
                        return .Expired
                    }
            }else if status == 4{
                return .Cancelled
            }else{
                // Calculate expiration time if status is not explicitly set
                let sentAtSeconds = sentAt / 1000.0
                let expirationTimestamp = sentAtSeconds + Double((metaData?.requestAPaymentExpiryTime ?? 0) * 60) // expireAt is in minutes
                let currentTimestamp = Date().timeIntervalSince1970

                // Check if the current time exceeds the expiration timestamp
                if currentTimestamp >= expirationTimestamp {
                    return .Expired
                } else {
                    return .ActiveRequest
                }
            }
        }else{
            return .ActiveRequest
        }
    }
    
    public class func getDineUserStatus(myUserId: String, metaData: MetaDataDB?) -> ISMChatPaymentRequestStatus {
        // Check the status of the matched member
        if metaData?.status == 1{
            return .Accepted
        }else if metaData?.status == 2{
            return .Rejected
        }else{
            return .Accepted
        }
    }
    
    public class func getDineInStatus(myUserId: String, metaData: MetaDataDB?, sentAt: Double) -> ISMChatPaymentRequestStatus {
        // Retrieve the member from paymentRequestedMembers matching myUserId
        guard let inviteMembers = metaData?.inviteMembers else {
            return .ActiveRequest // Default status if no members are found
        }
        // Find the specific member with myUserId
        guard let member = inviteMembers.first(where: { $0.userId == myUserId }) else {
            return .ActiveRequest // Default status if no matching member is found
        }
        
        if let reschduled = metaData?.inviteRescheduledTimestamp, reschduled != 0{
            return .Rescheduled
        }

        // Check the status of the matched member
        if let status = member.status {
            if status == 1{
                return .Accepted
            }else if status == 2{
                return .Rejected
            }else if status == 3{
                // Check if any other user's status is 1 (Accepted)
                    if inviteMembers.contains(where: { $0.userId != myUserId && $0.status == 1 }) {
                        return .PayedByOther
                    }else{
                        return .Expired
                    }
            }else if status == 4{
                return .Cancelled
            }else{
                // Calculate expiration time if status is not explicitly set
                let sentAtSeconds = sentAt / 1000.0
                let expirationTimestamp = sentAtSeconds + Double((metaData?.requestAPaymentExpiryTime ?? 0) * 60) // expireAt is in minutes
                let currentTimestamp = Date().timeIntervalSince1970

                // Check if the current time exceeds the expiration timestamp
                if currentTimestamp >= expirationTimestamp {
                    return .Expired
                } else {
                    return .ActiveRequest
                }
            }
        }else{
            return .ActiveRequest
        }
    }
    
    //MARK: - GET EMOJI
    
    public class func getEmoji(valueString : String) -> String{
        for case let emojiReaction in ISMChatEmojiReaction.allCases {
            if emojiReaction.info.valueString == valueString {
                return emojiReaction.info.emoji
            }
        }
        return ""
    }
    
    public class func shouldShowPlaceholder(avatar: String) -> Bool {
        return avatar == "https://res.cloudinary.com/dxkoc9aao/image/upload/v1616075844/kesvhgzyiwchzge7qlsz_yfrh9x.jpg" ||
        avatar.isEmpty ||
        avatar == "https://admin-media.isometrik.io/profile/def_profile.png" ||
        avatar.contains("svg") || avatar == "https://www.gravatar.com/avatar/?d=identicon" || avatar == "https://cdn.getfudo.com/adminAssets/0/0/Logo.png"
    }
    
    //MARK: - Convert sec to min and hr
    public func covertSecToMinAndHour(seconds : Int) -> String{
        let (_,m,s) = (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
        let sec : String = s < 10 ? "0\(s)" : "\(s)"
        return "\(m):\(sec)"
    }
    
    //MARK: - GET File Date
    public func getFileDate(for file: URL) -> Date {
        if let attributes = try? FileManager.default.attributesOfItem(atPath: file.path) as [FileAttributeKey: Any],
            let creationDate = attributes[FileAttributeKey.creationDate] as? Date {
            return creationDate
        } else {
            return Date()
        }
    }
    public func returnLatitude(string : String) -> String{
        let newURL = URL(string: string)!
        let coordinate = newURL.valueOf("query")
        let values = coordinate?.split(separator: ",")
        let latitude = String(values?[0] ?? "")
        return (latitude)
    }
    public func convertLatitudeStringToDouble(latitudeString: String) -> CLLocationDegrees? {
        if let latitude = Double(latitudeString) {
            return CLLocationDegrees(latitude)
        } else {
            return nil
        }
    }
    
    public func returnLongitude(string : String) -> String{
        let newURL = URL(string: string)!
        let coordinate = newURL.valueOf("query")
        let values = coordinate?.split(separator: ",")
        let longitude = String(values?[1] ?? "")
        return longitude
    }
    
    public func convertLongituteStringToDouble(latitudeString: String) -> CLLocationDegrees? {
        if let latitude = Double(latitudeString) {
            return CLLocationDegrees(latitude)
        } else {
            return nil
        }
    }
    
    
    //MARK: - CONVERT VIDEOURL TO IMAGE THUMBNAIL
    
    public class func generateThumbnailImageURL(from videoURL: URL, completion: @escaping (URL?) -> Void) {
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
                    ISMChatHelper.print("Error saving thumbnail image: \(error)")
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        } catch {
            ISMChatHelper.print("Error generating thumbnail image: \(error)")
            completion(nil)
        }
    }
    
    //MARK: - COMPRESS IMAGE
    public class func compressImage(image: URL) -> UIImage? {
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
    
    public func pdfThumbnail(url: URL, width: CGFloat = 240) -> UIImage? {
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
    
    public class  func getAddressFromLatLon(Latitude: String,Longitude: String, completion:@escaping(String?)->()){
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
                ISMChatHelper.print("reverse geodcode fail: \(error!.localizedDescription)")
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
    
    public class  func getFileNameFromURL(url: URL) -> String {
        let filename = url.lastPathComponent
        let components = filename.components(separatedBy: "_")
        if let lastComponent = components.last {
            return lastComponent
        }else{
            return url.lastPathComponent
        }
    }
    
    public class func parseJSONString(jsonString: String) -> (count: Int, firstDisplayName: String?) {
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
    
    public class  func pdfThumbnail(url: URL, width: CGFloat = 240, _ completion: @escaping ((UIImage?) -> Void)) {
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
    
    public class func getExtensionFromURL(url: URL) -> String? {
        let filename = url.lastPathComponent
        let components = filename.components(separatedBy: "_")
        guard let lastComponent = components.last else { return "" }
        return NSURL(fileURLWithPath: lastComponent).pathExtension
    }
    
    public class func subscribeFCM(userId : String) -> String{
        return "chat-\(userId)"
//        Messaging.messaging().subscribe(toTopic: "chat-\(userId)") { (error) in
//            if error != nil {
//                print("errror fcm topic ", error as Any)
//            }
//        }
    }
    
//    unsubscribe all fcm topics
    public class func unSubscribeFCM(userId : String) -> String{
        return "chat-\(userId)"
//        Messaging.messaging().unsubscribe(fromTopic: "chat-\(userId)")
    }
    
    public class func subscribeTopic(name : String) -> String{
        return name
//        Messaging.messaging().subscribe(toTopic: "\(name)") { (error) in
//            if error != nil {
//                print("errror subscribing topic ", error as Any)
//            }
//        }
    }
    
//    unsubscribe all fcm topics
    public class func unSubscribeTopic(name : String) -> String{
        return name
//        Messaging.messaging().unsubscribe(fromTopic: "\(name)")
    }
    
    public class func getVideoSize(_ url: URL) async -> CGSize {
        let videoAsset = AVURLAsset(url : url)

        let videoAssetTrack = try? await videoAsset.loadTracks(withMediaType: .video).first
        let naturalSize = (try? await videoAssetTrack?.load(.naturalSize)) ?? .zero
        let transform = try? await videoAssetTrack?.load(.preferredTransform)
        if (transform?.tx == naturalSize.width && transform?.ty == naturalSize.height) || (transform?.tx == 0 && transform?.ty == 0) {
            return naturalSize
        } else {
            return CGSize(width: naturalSize.height, height: naturalSize.width)
        }
    }
    
    public class func getThumbnailImage(url : String) -> UIImage? {
        
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
    
    public class func createImageURL() -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent("\(UUID()).jpg")
        return fileURL
    }
    
    public class func sentAtTimeForLocalDB() -> Double {
        // Create a DateFormatter instance
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        // Set the desired date format
        dateFormatter.dateFormat = "h:mm a"
        let currentTime = Date()
        let timeInSeconds = currentTime.timeIntervalSince1970
        return timeInSeconds
    }
    
    public class func downloadMedia(from url: String) {
        guard let mediaURL = URL(string: url) else {
            ISMChatHelper.print("Invalid URL: \(url)")
            return
        }
        
        // Fetch the media data from URL
        URLSession.shared.dataTask(with: mediaURL) { data, response, error in
            if let error = error {
                ISMChatHelper.print("Error downloading media: \(error)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                ISMChatHelper.print("Invalid response")
                return
            }
            
            // Check MIME type to determine if it's an image or video
            if let mimeType = httpResponse.mimeType {
                if mimeType.hasPrefix("image") {
                    // Handle image
                    guard let data = data, let image = UIImage(data: data) else {
                        ISMChatHelper.print("Invalid image data")
                        return
                    }
                    self.saveImageToGallery(image: image)
                    
                } else if mimeType.hasPrefix("video") || mimeType == "binary/octet-stream" {
                    // Handle video (even if MIME type is binary/octet-stream)
                    guard let data = data else {
                        ISMChatHelper.print("Invalid video data")
                        return
                    }
                    
                    // Check file extension to infer media type if MIME type is generic
                    if mediaURL.pathExtension.lowercased() == "mp4" || mimeType == "video/mp4" {
                        self.saveVideoToGallery(videoData: data, url: mediaURL)
                    } else {
                        ISMChatHelper.print("Unsupported binary content or unknown file type.")
                    }
                } else {
                    ISMChatHelper.print("Unsupported MIME type: \(mimeType)")
                }
            }
            
        }.resume()
    }

    // Helper function to save image to the photo library
    private class func saveImageToGallery(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        ISMChatHelper.print("Image saved to gallery")
    }

    // Helper function to save video to the photo library
    private class func saveVideoToGallery(videoData: Data, url: URL) {
        // Save video file to temporary location
        let temporaryDirectory = NSTemporaryDirectory()
        let temporaryFileURL = URL(fileURLWithPath: temporaryDirectory).appendingPathComponent(url.lastPathComponent)
        
        do {
            try videoData.write(to: temporaryFileURL)
            
            // Save video to the photo library
            PHPhotoLibrary.shared().performChanges({
                PHAssetCreationRequest.forAsset().addResource(with: .video, fileURL: temporaryFileURL, options: nil)
            }) { success, error in
                if let error = error {
                    ISMChatHelper.print("Error saving video to gallery: \(error)")
                } else {
                    ISMChatHelper.print("Video saved to gallery")
                }
            }
            
        } catch {
            ISMChatHelper.print("Error writing video to temporary file: \(error)")
        }
    }

}

extension ISMChatHelper{
    //MARK: - SECTION HEADER
    
    
    public class func getOpponentForOneToOneGroup(myUserId : String,members : [ISMChatGroupMember]) -> ISMChatGroupMember?{
        // Ensure there are exactly 2 members in the group
        guard members.count == 2 else {
            return nil
        }
        // Find the opponent by filtering out the member with myUserId
        let opponent = members.first { $0.userId != myUserId }
        
        // Return the opponent in the completion handler
        return (opponent)
    }
    
    public class func formatDateRange(startDate: String, endDate: String) -> String? {
        // Create a DateFormatter to parse the input date string
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        // Create a DateFormatter to format the output date string
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd MMMM" // Format for "10 October"

        // Convert the start and end date strings to Date objects
        guard let start = inputFormatter.date(from: startDate),
              let end = inputFormatter.date(from: endDate) else {
            return nil
        }

        // Format the Date objects to the desired output format
        let formattedStartDate = outputFormatter.string(from: start)
        let formattedEndDate = outputFormatter.string(from: end)
        
        // Combine the formatted start and end dates into a single string
        return "\(formattedStartDate) - \(formattedEndDate)"
    }
}
