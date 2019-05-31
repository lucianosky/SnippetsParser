//
//  main.swift
//  SnippetsParser
//
//  Created by Luciano Sclovsky on 12/06/18.
//  Copyright © 2018 Skyffee. All rights reserved.
//

import Foundation

func gitClone(_ gitSource: String, _ targetFolder: String) -> Bool {
    print("Cloning repo: \(gitSource)")
    let p = Process()
    do {
        try p.clone(repo: gitSource, path: targetFolder)
        p.waitUntilExit()
    } catch {
        print("Error cloning repo.")
        return false
    }
    print("Repo cloned.")
    return true
}

func installation() -> Bool {
    let macOSHelper = MacOSHelper()
    
    print("Thank you very much for using this early version of SnippetsParser! :)")
    if CommandLine.argc > 1 {
        print("Warning: SwiftParser takes no arguments")
    }
    
    guard let docUrl = macOSHelper.getFolderUrl(for: .documentDirectory),
        let libUrl = macOSHelper.getFolderUrl(for: .libraryDirectory) else {
            print("An error happened reading document or library folders")
            return false
    }
    
    let userDataUrl = libUrl.appendingPathComponent("Developer/Xcode/UserData")
    if !macOSHelper.fileExists(atPath: userDataUrl.path) {
        print("Error: could not find expected UserData folder at: \(userDataUrl.path)")
        return false
    }
    
    let codeSnippetsUrl = userDataUrl.appendingPathComponent("CodeSnippets")
    if !macOSHelper.createFolderIfNotExists(path: codeSnippetsUrl.path) {
        return false
    }
    
    let targetUrl = docUrl.appendingPathComponent("1000Snippets")
    guard macOSHelper.deleteFolderIfExists(path: targetUrl.path, description: "github clone") else {
        return false
    }
    
    let gitSource = "https://github.com/lucianosky/1000Snippets.git"
    if !gitClone(gitSource, targetUrl.path) {
        return false
    }
    
    Snippet.searchForSnippets(sourceUrl: targetUrl, saveUrl: codeSnippetsUrl)
    print("Successfully installed snippets for Xcode.")
    return true
}

if installation() {
    exit(0)
} else {
    exit(1)
}
