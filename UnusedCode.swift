struct SnippetToken {
    let token: String
    let quoted: Bool
}

let cwd = FileManager.default.currentDirectoryPath
print("script run from:\n" + cwd)

var snippet: [String: Any] = [
    "snippet": 1,
    "title": "UIButton change text",
    "links": [
        "https://stackoverflow.com/questions/1033763/is-it-possible-to-update-uibutton-title-text-programmatically"
    ]
]


do {
    if let path = Bundle.main.path(forResource: "template", ofType:"txt") {
        let url = URL(fileURLWithPath: path)
        let text = try String(contentsOf: url, encoding: .utf8)
        return text
    } else {
        print("erro!!")
        return ""
    }
} catch {
    print("error!")
    return ""
}

func strategy1(url: URL) {
    let helper = MacOSHelper()
    let swiftFiles = helper.recursiveFindSwiftFiles(folder: url, swiftFiles: [URL]() )
    let count = swiftFiles.count
    print("Found \(count) swift file\(count != 1 ? "s" : "")")
    swiftFiles.forEach { (url) in
        let snippetTokens = parseSwiftFile(url)
        let snippets = extractSnippets(snippetTokens: snippetTokens)
        let count2 = snippets.count
        print("Found \(count2) snippet\(count2 != 1 ? "s" : "")")
        snippets.forEach { (snippet) in
            print(snippet)
        }
    }
}

func parseSwiftFile(_ url: URL) -> [SnippetToken] {
    print("Parsing \(url.absoluteString)")
    do {
        var snippetTokens = [SnippetToken]()
        let text = try String(contentsOf: url, encoding: .utf8)
        let tokens = text.replacingOccurrences(of: "\n", with: " ").components(separatedBy: "\"")
        for (index, token) in tokens.enumerated() {
            let isOdd = index % 2 == 1
            if isOdd {
                snippetTokens.append(SnippetToken(token: token, quoted: isOdd))
            } else {
                let evenTokens = token.components(separatedBy: " ").filter { (str) -> Bool in
                    return str.count > 0
                }
                evenTokens.forEach { (str) in
                    snippetTokens.append(SnippetToken(token: str, quoted: false))
                }
            }
        }
        return snippetTokens
    } catch {
        print("error!")
        return []
    }
}

func extractSnippets(snippetTokens: [SnippetToken]) -> [Snippet] {
    print(snippetTokens.count)
    var snippets = [Snippet]()
    for i in 0..<snippetTokens.count-8 {
        let token = snippetTokens[i]
        let str = token.quoted ? "\"\(token.token)\"" : token.token
        print(i, str)
        // print(i, snippetTokens[i])
        if snippetTokens[i].token == "[" && snippetTokens[i+1].token == "snippet" && snippetTokens[i+2].token == ":" {
            var idStr = snippetTokens[i+3].token
            if idStr.last == "," {
                idStr = String(idStr.dropLast())
            }
            let id = Int(idStr) ?? 0
            let title = snippetTokens[i+6].token
            var links = [String]()
            if snippetTokens[i+8].token == "links" {
                var j = i + 11
                while snippetTokens[j].token != "]" {
                    if snippetTokens[j].token != "," {
                        links.append(snippetTokens[j].token)
                    }
                    j = j + 1
                }
            }
            let code = [String]()
            let snippet = Snippet(id: id, title: title, links: links, code: code)
            snippets.append(snippet)
        }
    }
    return snippets
}
