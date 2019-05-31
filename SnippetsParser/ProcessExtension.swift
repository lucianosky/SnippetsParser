//
//  ProcessExtension.swift
//  SnippetsParser
//
//  Created by Luciano Sclovsky on 31/05/19.
//  Copyright © 2019 Skyffee. All rights reserved.
//

import Foundation

extension Process {
    
    private static let gitExecURL = URL(fileURLWithPath: "/usr/bin/git")
    
    public func clone(repo: String, path: String) throws {
        executableURL = Process.gitExecURL
        arguments = ["clone", repo, path]
        try run()
    }
    
}

