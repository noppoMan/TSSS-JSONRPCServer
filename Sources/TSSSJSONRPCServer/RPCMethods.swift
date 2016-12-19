//
//  Methods.swift
//  TSSSJSONRPCServer
//
//  Created by Yuki Takei on 2016/11/30.
//
//

import Foundation
import SwiftyJSON

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

func plzXmasImage() throws  -> [String: String] {
    
    let client = try HTTPClient(url: URL(string: "https://api.gifly.jp/v1/searches?tags=xmas")!)
    try client.open()
    let response = try client.request()
    
    guard let data = response.buffer else {
        return [:]
    }
    
    let json = JSON(data: data)
    
    guard let items = json["items"].array else {
        return [:]
    }
    let index = Int(arc4random_uniform(UInt32(items.count)))
    return ["url": items[index]["image"].stringValue]
}
