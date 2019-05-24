//
//  main.swift
//  SnippetsParser
//
//  Created by Luciano Sclovsky on 12/06/18.
//  Copyright © 2018 Skyffee. All rights reserved.
//

import Foundation

func strategy(sourceUrl: URL, saveUrl: URL) {
    let helper = MacOSHelper()
    let swiftFiles = helper.recursiveFindSwiftFiles(folder: sourceUrl, swiftFiles: [URL]() )
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

extension Process {
    
    private static let gitExecURL = URL(fileURLWithPath: "/usr/bin/git")
    
    public func clone(repo: String, path: String) throws {
        executableURL = Process.gitExecURL
        arguments = ["clone", repo, path]
        try run()
    }
    
}

func deleteFileIfExists(path: String) -> Bool {
    if FileManager.default.fileExists(atPath: path) {
        print("file exists")
        do {
            try FileManager.default.removeItem(atPath: path)
            print("Deleted previous version of 1000snippets")
        }
        catch let error as NSError {
            print("Could not delete previous version of 1000snippets: \(error)")
            return false
        }
    }
    return true
}

func documentsUrl() -> URL? {
    //print(try! FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: true))
    return  try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
}

func gitClone(_ gitSource: String, _ targetFolder: String) -> Bool {
    guard deleteFileIfExists(path: targetFolder) else {
        print("error deleting folder")
        return false
    }
    print("Will clone repo")
    let p = Process()
    do {
        try p.clone(repo: gitSource, path: targetFolder)
        p.waitUntilExit()
    } catch {
        print("Error cloning repo")
        return false
    }
    print("Done")
    return true
}

print("Swift Parser")
if CommandLine.argc < 3 {
    print("usage: SwiftParser <pathToProject> <pathToSnippets>")
    exit(1)
}

guard let docsUrl = documentsUrl() else {
    print("Error fetching documents URL")
    exit(1)
}
let gitSource = "https://github.com/lucianosky/1000Snippets.git"
let targetFolder = docsUrl.path + "/1000SnippetsAppCode"
_ = gitClone(gitSource, targetFolder)

let sourceUrl = URL(fileURLWithPath: targetFolder, isDirectory: true)
//let sourceUrl = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
let saveUrl = URL(fileURLWithPath: CommandLine.arguments[2], isDirectory: true)
strategy(sourceUrl: sourceUrl, saveUrl: saveUrl)

print("finished...")
