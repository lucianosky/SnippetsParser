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

func downloadFromGithub() -> Bool {
    print("Will download from github")
    guard let githubURL = URL(string: "https://github.com/lucianosky/1000snippets/archive/master.zip"),
          let documentsUrl = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    else {
        return false
    }
    let destination = documentsUrl.appendingPathComponent("1000snippets.zip")

    if FileManager.default.fileExists(atPath: destination.path) {
        do {
            try FileManager.default.removeItem(atPath: destination.path)
            print("Deleted previous version of 1000snippets")
        }
        catch let error as NSError {
            print("Could not delete previous version of 1000snippets: \(error)")
            return false
        }
    }
        
    let semaphore = DispatchSemaphore(value: 0)
    URLSession.shared.downloadTask(with: githubURL, completionHandler: { (location, response, error) in
        // after downloading your data you need to save it to your destination url
        guard
            let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
            let mimeType = response?.mimeType, mimeType.hasPrefix("application/zip"),
            let location = location, error == nil
            else { return }
        do {
            try FileManager.default.moveItem(at: location, to: destination)
        } catch {
            print("Could not save file: \(error)")
        }
        print("done!")
        semaphore.signal()
    }).resume()
    print("downloading file...")
    semaphore.wait()
    return true
}

print("Swift Parser")
if CommandLine.argc < 3 {
    print("usage: SwiftParser <pathToProject> <pathToSnippets>")
    exit(1)
}

_ = downloadFromGithub()
print("continuando...")

let url = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
let saveUrl = URL(fileURLWithPath: CommandLine.arguments[2], isDirectory: true)
strategy(url: url, saveUrl: saveUrl)

print("finished...")
