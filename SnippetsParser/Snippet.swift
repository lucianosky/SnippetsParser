//
//  Snippet.swift
//  SnippetsParser
//
//  Created by Luciano Sclovsky on 18/11/18.
//  Copyright © 2018 Skyffee. All rights reserved.
//

import Foundation

struct Snippet {
    let id: Int
    let title: String
    let links: [String]
    let code: [String]
    
    var idZeros: String {
        return String(format: "%04d", id)
    }
    
    static let macOSHelper = MacOSHelper()
    
    static func searchForSnippets(sourceUrl: URL, saveUrl: URL) {
        let swiftFiles = macOSHelper.recursiveFindSwiftFiles(folder: sourceUrl, swiftFiles: [URL]() )
        let filesCount = swiftFiles.count
        print("Found \(filesCount) swift file\(filesCount != 1 ? "s" : "")")
        swiftFiles.forEach { (url) in
            if let lines = macOSHelper.getFileLines(url: url) {
                let snippets = Snippet.linesToSnippets(lines: lines)
                let snippetsInFileCount = snippets.count
                print("\(snippetsInFileCount) snippet\(snippetsInFileCount != 1 ? "s" : "") at \(url.lastPathComponent)")
                snippets.sorted(by: { $0.id < $1.id }).forEach({ (snippet) in
                    // snippet.printSnippet(false)
                    let plist = snippet.toPlist()
                    let fileUrl = saveUrl.appendingPathComponent("snippet_\(snippet.idZeros).codesnippet")
                    do {
                        try plist.write(to: fileUrl, atomically: true, encoding: String.Encoding.utf8)
                    } catch {
                        print("error")
                    }
                })
            }
        }
    }

    func printSnippet(_ withCodeAndLinks: Bool = true) {
        print("#\(idZeros) \(title)")
        if withCodeAndLinks {
            print("Code:")
            code.forEach { (codeLine) in
                print(codeLine)
            }
            print("Links:")
            links.forEach { (link) in
                print(link)
            }
            print("")
        }
    }
    
    func toPlist() -> String {
        let resource = "template"
        let type = "txt"
        guard let template = Snippet.macOSHelper.getResourceText(forResource: resource, ofType: type) else {
            return ""
        }
        let code = self.code.joined(separator: "\n")
        let plist = template
            .replacingOccurrences(of: "@title", with: "1000 Snippets \(id) \(title)")
            .replacingOccurrences(of: "@code", with: code)
        return plist
    }
    
    static func linesToSnippets(lines: [String]) -> [Snippet] {
        var snippets = [Snippet]()
        var i = 0
        while i < lines.count {
            let line = lines[i]
            if line.hasPrefix("_ = Snippet( ") {
                let index = line.index(line.startIndex, offsetBy: 13)
                let substring = line[index...]
                let array = substring.components(separatedBy: ",").map{$0.trimmingCharacters(in: .whitespacesAndNewlines).dropQuotationMarks()}
                let id = Int(array[0])!
                let title = array[1]
                i += 1
                var links = [String]()
                while lines[i] != "])" {
                    links.append(lines[i].dropQuotationMarks())
                    i += 1
                }
                i += 1
                var code = [String]()
                while lines[i].count > 0 {
                    if lines[i] != "*/" {
                        code.append(lines[i])
                    }
                    i += 1
                }
                let snippet = Snippet(id: id, title: title, links: links, code: code)
                snippets.append(snippet)
            } else {
                i += 1
            }
        }
        return snippets
    }

    
}

