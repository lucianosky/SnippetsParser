//
//  MacOSHelper.swift
//  SnippetsParser
//
//  Created by Luciano Sclovsky on 18/11/18.
//  Copyright © 2018 Skyffee. All rights reserved.
//

import Foundation
import Cocoa

class MacOSHelper {
    
    func getFolderUrl(for directory: FileManager.SearchPathDirectory) -> URL? {
        return try? FileManager.default.url(for: directory, in: .userDomainMask, appropriateFor: nil, create: true)
    }
    
    func fileExists(atPath path: String) -> Bool {
        return FileManager.default.fileExists(atPath: path)
    }
    
    func deleteFolderIfExists(path: String, description: String) -> Bool {
        if FileManager.default.fileExists(atPath: path) {
            print("Found previous \(description) folder of app at \(path).")
            print("Confirm delete? (y)")
            let response = readLine()
            guard let r = response, r.uppercased() == "Y" else {
                print("Operation aborted by user.")
                return false
            }
            do {
                try FileManager.default.removeItem(atPath: path)
                print("Deleted previous folder.")
            }
            catch let error as NSError {
                print("Could not delete previous folder: \(error.localizedDescription)")
                return false
            }
        }
        return true
    }

    func createFolderIfNotExists(path: String) -> Bool {
        if !FileManager.default.fileExists(atPath: path) {
            do {
                try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: false, attributes: nil)
                print("Created folder: \(path)")
            } catch let error as NSError {
                print(error.localizedDescription)
                return false
            }
        }
        return true
    }

    func recursiveFindSwiftFiles(folder: URL, swiftFiles: [URL] ) -> [URL] {
        let fileManager = FileManager.default
        var result = swiftFiles
        var urls = [URL]()
        do {
            let contents = try fileManager.contentsOfDirectory(atPath: folder.path)
            urls = contents
                .filter { $0.first != "." }
                .map { return folder.appendingPathComponent($0) }
        } catch {
            return swiftFiles
        }
        urls.forEach { (url) in
            if url.hasDirectoryPath {
                result = self.recursiveFindSwiftFiles(folder: url, swiftFiles: result)
            } else {
                if url.pathExtension == "swift" {
                    result.append(url)
                }
            }
        }
        return result
    }
    
    func getResourceText(forResource resource: String, ofType type: String) -> String? {
        let bundle = Bundle.main
        guard let filepath = bundle.path(forResource: resource, ofType: "txt")  else {
            return "an error happened on getResourceText"
        }
        do {
            return try String(contentsOfFile: filepath)
        } catch {
            print("an error happened on getResourceText")
            return nil
        }
    }
    
    func getFileLines(url: URL) -> [String]? {
        do {
            let text = try String(contentsOf: url, encoding: .utf8)
            let lines = text.components(separatedBy: .newlines).map({ (line) -> String in
                return line.trimmingCharacters(in: .whitespacesAndNewlines)
            })
            return lines
        } catch {
            print("an error happened on getFileLines")
            return nil
        }
    }
    
}


