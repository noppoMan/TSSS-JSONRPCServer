//
//  Methods.swift
//  TSSSJSONRPCServer
//
//  Created by Yuki Takei on 2016/11/30.
//
//

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
