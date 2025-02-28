//
//  LocalDBManager+Messages.swift
//  IsometrikChat
//
//  Created by Rasika Bharati on 26/02/25.
//

import SwiftData
import Foundation

extension LocalStorageManager{
    public func fetchAllMessages() -> [ISMChatMessagesDB] {
        do {
            let descriptor = FetchDescriptor<ISMChatMessagesDB>(predicate: #Predicate {!$0.isDelete})
            let messages = try modelContext.fetch(descriptor)
            return messages
        } catch {
            print("Fetch Error: \(error)")
            return []
        }
    }
    
    public func fetchAllMessagesToShowInList() -> [[ISMChatMessagesDB]] {
        do {
            let descriptor = FetchDescriptor<ISMChatMessagesDB>(predicate: #Predicate {!$0.isDelete})
            let messages = try modelContext.fetch(descriptor)
            
            var res = [[ISMChatMessagesDB]]()
            let groupedMessages = Dictionary(grouping: messages) { (element) -> Date in
                
                let timeStamp = element.sentAt
                let unixTimeStamp: Double = Double(timeStamp) / 1000.0
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd/MM/yyyy"
                
                let strDate = dateFormatter.string(from: Date(timeIntervalSince1970: unixTimeStamp))
                return dateFormatter.date(from: strDate) ?? Date()
            }
            
            let sortedKeys = groupedMessages.keys.sorted()
            sortedKeys.forEach { key in
                var values = groupedMessages[key]
                values?.sort { Double($0.sentAt) / 1000.0 < Double($1.sentAt) / 1000.0 }
                res.append(values ?? [])
            }
            
            return res
        } catch {
            print("Fetch Error: \(error)")
            return []
        }
    }
    
    //MARK: - fetch photo and videos
//    public func fetchPhotosAndVideos(conId: String) {
//        do {
//            let descriptor = FetchDescriptor<ISMChatMediaDB>(
//                predicate: #Predicate {
//                    !$0.isDelete && $0.conversationId == conId &&
//                    ($0.customType == ISMChatMediaType.Image.value ||
//                     $0.customType == ISMChatMediaType.Video.value ||
//                     $0.customType == ISMChatMediaType.gif.value)
//                }
//            )
//            self.medias = try modelContext.fetch(descriptor)
//        } catch {
//            print("Fetch Error: \(error)")
//        }
//    }
//
//    //MARK: - fetch files
//    public func fetchFiles(conId: String) {
//        do {
//            let descriptor = FetchDescriptor<ISMChatMediaDB>(
//                predicate: #Predicate {
//                    !$0.isDelete && $0.conversationId == conId &&
//                    $0.customType == ISMChatMediaType.File.value
//                }
//            )
//            self.filesMedia = try modelContext.fetch(descriptor)
//        } catch {
//            print("Fetch Error: \(error)")
//        }
//    }
//
//    //MARK: - fetch links
//    public func fetchLinks(conId: String) {
//        do {
//            let descriptor = FetchDescriptor<ISMChatMessagesDB>(
//                predicate: #Predicate {
//                    !$0.isDelete && $0.conversationId == conId
//                }
//            )
//            let messages = try modelContext.fetch(descriptor)
//            
//            // Filter messages that contain "www" or "https" and do not contain "map"
//            let filteredMessages = messages.filter { message in
//                message.body.isValidURL && !message.body.contains("map")
//            }
//            
//            self.linksMedia = filteredMessages
//        } catch {
//            print("Fetch Error: \(error)")
//        }
//    }

}
