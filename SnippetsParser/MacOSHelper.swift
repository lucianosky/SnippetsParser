//
//  MacOSHelper.swift
//  swiftparser
//
//  Created by Luciano Sclovsky on 18/11/18.
//  Copyright © 2018 Skyffee. All rights reserved.
//

import Foundation
import Cocoa

class MacOSHelper {
    
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
    
}


