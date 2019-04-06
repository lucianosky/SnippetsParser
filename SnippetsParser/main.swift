//
//  main.swift
//  SnippetsParser
//
//  Created by Luciano Sclovsky on 12/06/18.
//  Copyright © 2018 Skyffee. All rights reserved.
//

import Foundation

func strategy(url: URL, saveUrl: URL) {
    let helper = MacOSHelper()
    let swiftFiles = helper.recursiveFindSwiftFiles(folder: url, swiftFiles: [URL]() )
    let count = swiftFiles.count
    print("Found \(count) swift file\(count != 1 ? "s" : "")")
    swiftFiles.forEach { (url) in
        if let lines = FileHelper.getFileLines(url: url) {
            print("Parsing file \(url.lastPathComponent)")
            let snippets = Snippet.linesToSnippets(lines: lines)
            let count2 = snippets.count
            print("Found \(count2) snippet\(count2 != 1 ? "s" : "")")
            snippets.sorted(by: { $0.id < $1.id }).forEach({ (snippet) in
                snippet.printSnippet()
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

print("Swift Parser")
if CommandLine.argc < 3 {
    print("usage: SwiftParser <pathToProject> <pathToSnippets>")
    exit(1)
}

let url = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
let saveUrl = URL(fileURLWithPath: CommandLine.arguments[2], isDirectory: true)
strategy(url: url, saveUrl: saveUrl)

