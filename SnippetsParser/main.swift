//
//  main.swift
//  SnippetsParser
//
//  Created by Luciano Sclovsky on 12/06/18.
//  Copyright © 2018 Skyffee. All rights reserved.
//

import Foundation
import AppKit

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
    guard macOSHelper.fileExists(atPath: userDataUrl.path) else {
        print("Error: could not find expected UserData folder at: \(userDataUrl.path)")
        return false
    }
    
    let codeSnippetsUrl = userDataUrl.appendingPathComponent("CodeSnippets")
    guard macOSHelper.createFolderIfNotExists(path: codeSnippetsUrl.path) else {
        return false
    }
    
    let targetUrl = docUrl.appendingPathComponent("1000Snippets")
    let msg = "Found previous github clone folder of app at \(targetUrl.path).\nConfirm delete? (y)"

    guard macOSHelper.deleteFolderIfExists(path: targetUrl.path, confirmationMessage: msg) else {
        print("Operation aborted by user.")
        return false
    }
    
    let gitSource = "https://github.com/lucianosky/1000Snippets.git"
    let process = Process()
    guard process.gitClone(gitSource, targetUrl.path) else {
        return false
    }
    
    Snippet.searchForSnippets(sourceUrl: targetUrl, saveUrl: codeSnippetsUrl)
    print("Successfully installed snippets for Xcode.")

    _ = macOSHelper.deleteFolderIfExists(path: targetUrl.path, confirmationMessage: "Remove 1000Snippets git clone version? (y)")

    let nunningApps = NSWorkspace.shared.runningApplications.filter { (app) -> Bool in
        // filter for user apps: app.activationPolicy == .regular
        return app.localizedName == "Xcode"
    }
    if nunningApps.count >= 1 {
        print("Xcode is running, please restart it to install snippets.")
    }

    return true
}

if installation() {
    exit(0)
} else {
    exit(1)
}
