//
//  StringExtension.swift
//  swiftparser
//
//  Created by Luciano Sclovsky on 18/11/18.
//  Copyright © 2018 Skyffee. All rights reserved.
//

import Foundation

extension String {

    func dropLastComma() -> String {
        if self.last == "," {
            return String(self.dropLast())
        } else {
            return self
        }
    }

    func dropQuotationMarks() -> String {
        var result = self
        if result.first == "\"" {
            result = String(result.dropFirst())
        }
        if result.last == "\"" {
            result = String(result.dropLast())
        }
        return result
    }
    
    func getInt() -> Int {
        let tokens = self.dropLastComma().components(separatedBy: ":")
        let token = tokens[1].trimmingCharacters(in: .whitespaces)
        return Int(token) ?? 0
    }
    
    func getString() -> String {
        let tokens = self.dropLastComma().components(separatedBy: ":")
        let token = tokens[1].trimmingCharacters(in: .whitespaces).dropQuotationMarks()
        return token
    }
    
}
