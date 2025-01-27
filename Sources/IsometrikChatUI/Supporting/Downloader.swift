//
//  Downloader.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 27/10/23.
//

import Foundation

/// A utility class for handling file downloads both synchronously and asynchronously
class FileDownloader {

    /// Downloads a file synchronously from a given URL and saves it to the app's documents directory
    /// - Parameters:
    ///   - url: The source URL of the file to download
    ///   - completion: A closure that returns either the local file path (String) or an error
    static func loadFileSync(url: URL, completion: @escaping (String?, Error?) -> Void)
    {
        // Get the documents directory URL
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        // Create destination URL for the downloaded file
        let destinationUrl = documentsUrl.appendingPathComponent(url.lastPathComponent)

        // Check if file already exists at destination
        if FileManager().fileExists(atPath: destinationUrl.path)
        {
            print("File already exists [\(destinationUrl.path)]")
            completion(destinationUrl.path, nil)
        }
        // Attempt to download and save the file
        else if let dataFromURL = NSData(contentsOf: url)
        {
            // Try to write the downloaded data to destination
            if dataFromURL.write(to: destinationUrl, atomically: true)
            {
                print("file saved [\(destinationUrl.path)]")
                completion(destinationUrl.path, nil)
            }
            else
            {
                print("error saving file")
                let error = NSError(domain:"Error saving file", code:1001, userInfo:nil)
                completion(destinationUrl.path, error)
            }
        }
        else
        {
            let error = NSError(domain:"Error downloading file", code:1002, userInfo:nil)
            completion(destinationUrl.path, error)
        }
    }

    /// Downloads a file asynchronously from a given URL and saves it to the app's documents directory
    /// - Parameters:
    ///   - url: The source URL of the file to download
    ///   - completion: A closure that returns either the local file path (String) or an error
    static func loadFileAsync(url: URL, completion: @escaping (String?, Error?) -> Void)
    {
        // Get the documents directory URL
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        // Create destination URL for the downloaded file
        let destinationUrl = documentsUrl.appendingPathComponent(url.lastPathComponent)

        // Check if file already exists at destination
        if FileManager().fileExists(atPath: destinationUrl.path)
        {
            print("File already exists [\(destinationUrl.path)]")
            completion(destinationUrl.path, nil)
        }
        else
        {
            // Configure and create URL session for download
            let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            // Create download task
            let task = session.dataTask(with: request, completionHandler:
            {
                data, response, error in
                if error == nil
                {
                    if let response = response as? HTTPURLResponse
                    {
                        // Check for successful HTTP response
                        if response.statusCode == 200
                        {
                            if let data = data
                            {
                                // Attempt to write downloaded data to destination
                                if let _ = try? data.write(to: destinationUrl, options: Data.WritingOptions.atomic)
                                {
                                    completion(destinationUrl.path, error)
                                }
                                else
                                {
                                    completion(destinationUrl.path, error)
                                }
                            }
                            else
                            {
                                completion(destinationUrl.path, error)
                            }
                        }
                    }
                }
                else
                {
                    completion(destinationUrl.path, error)
                }
            })
            task.resume()
        }
    }
}
