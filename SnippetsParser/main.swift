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
                snippet.printSnippet(false)
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

func getFolderUrl(for directory: FileManager.SearchPathDirectory) -> URL? {
    return try? FileManager.default.url(for: directory, in: .userDomainMask, appropriateFor: nil, create: true)
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
if CommandLine.argc > 1 {
    print("Warning: SwiftParser takes no arguments")
}

guard let docUrl = getFolderUrl(for: .documentDirectory),
      let libUrl = getFolderUrl(for: .libraryDirectory) else {
    print("Error fetching folders")
    exit(1)
}

print(docUrl)
let targetUrl = docUrl.appendingPathComponent("1000SnippetsAppCode")
print(targetUrl, FileManager.default.fileExists(atPath: targetUrl.path))

print(libUrl)

let userDataUrl = libUrl.appendingPathComponent("Developer/Xcode/UserData")
print(userDataUrl, FileManager.default.fileExists(atPath: userDataUrl.path))

let codeSnippetsUrl = userDataUrl.appendingPathComponent("CodeSnippets")
print(codeSnippetsUrl, FileManager.default.fileExists(atPath: codeSnippetsUrl.path))

let gitSource = "https://github.com/lucianosky/1000Snippets.git"

_ = gitClone(gitSource, targetUrl.path)

strategy(sourceUrl: targetUrl, saveUrl: codeSnippetsUrl)

print("finished...")
