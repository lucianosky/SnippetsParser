//
//  FileHelper.swift
//  SnippetsParser
//
//  Created by Luciano Sclovsky on 18/11/18.
//  Copyright © 2018 Skyffee. All rights reserved.
//

import Foundation

class FileHelper {
    
    static func getResourceText(forResource resource: String, ofType type: String) -> String? {
        let bundle = Bundle.main
        guard let filepath = bundle.path(forResource: resource, ofType: "txt")  else {
            return "an error happened on FileHelper.getResourceText"
        }
        do {
            return try String(contentsOfFile: filepath)
        } catch {
            print("an error happened on FileHelper.getResourceText")
            return nil
        }
    }
    
    static func getFileLines(url: URL) -> [String]? {
        do {
            let text = try String(contentsOf: url, encoding: .utf8)
            let lines = text.components(separatedBy: .newlines).map({ (line) -> String in
                return line.trimmingCharacters(in: .whitespacesAndNewlines)
            })
            return lines
        } catch {
            print("an error happened on FileHelper.getFileLines")
            return nil
        }
    }

}
