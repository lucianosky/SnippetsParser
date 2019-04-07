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

