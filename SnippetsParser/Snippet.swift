//
//  Snippet.swift
//  swiftparser
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

    func printSnippet() {
        print(id)
        print(title)
        print("-links-")
        links.forEach { (link) in
            print(link)
        }
        print("-code-")
        code.forEach { (codeLine) in
            print(codeLine)
        }
        print("------")
    }
    
    func toPlist() -> String {
        let resource = "template"
        let type = "txt"
        guard let template = FileHelper.getResourceText(forResource: resource, ofType: type) else {
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
            if lines[i] == "snippet = [" {
                i += 1
                let id = lines[i].getInt()
                i += 1
                let title = lines[i].getString()
                i += 1
                var links = [String]()
                if lines[i] == "\"links\": [" {
                    i += 1
                    while lines[i] != "]" {
                        let line = lines[i].getString()
                        links.append(line)
                        i += 1
                    }
                    i += 1
                }
                i += 1
                var code = [String]()
                while lines[i].count > 0 {
                    code.append(lines[i])
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

