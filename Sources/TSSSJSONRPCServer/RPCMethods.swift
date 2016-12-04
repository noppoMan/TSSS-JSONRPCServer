//
//  Methods.swift
//  TSSSJSONRPCServer
//
//  Created by Yuki Takei on 2016/11/30.
//
//

import Foundation

func getWizards() -> [String] {
    return [
        "Harry Potter",
        "Hermione Granger",
        "Ron Weasley",
        "Luna Lovegood",
        "Ginny Weasley",
        "Professor Severus Snape"
    ]
}

func redisPing(_ tryCount: Int) -> [String] {
    let chan = Channel<String>.make(capacity: 1)
    let errorChan = Channel<Error>.make(capacity: 1)
    
    for _ in 0..<tryCount {
        go {
            do {
                let rep = try redis.command(.PING)
                try chan.send(rep.first!)
            } catch {
                try! errorChan.send(error)
            }
        }
    }
    
    var results = [String]()
    
    forSelect { done in
        when(chan) {
            results.append($0)
            if results.count == tryCount {
                done()
            }
        }
        
        when(errorChan) {
            results.append("\($0)")
            if results.count == tryCount {
                done()
            }
        }
    }
    
    return results
}

func plzLGTMImage() throws  -> [String: String] {
    
    let client = try HTTPClient(url: URL(string: "http://www.lgtm.in/g")!)
    try client.open()
    let response = try client.request()
    
    let data = response.buffer!
    let html = String(data: data, encoding: .utf8)!
    
    let regex = try! NSRegularExpression(pattern: "<meta name=\"twitter:image\" content=\"(.+)\"", options: [.caseInsensitive])
    
    if let match = regex.firstMatch(in: html, options: [], range: NSMakeRange(0, html.utf16.count)) {
        for n in 0..<match.numberOfRanges {
            if n == 0 {
                continue
            }
            let range = match.rangeAt(n)
            let start = html.index(html.startIndex, offsetBy: range.location)
            let end = html.index(html.startIndex, offsetBy: range.location+range.length)
            
            return ["url": html.substring(with: start..<end)]
        }
    }
    
    return [:]
}
