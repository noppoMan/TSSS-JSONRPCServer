//
//  main.swift
//  TSSS-JSONRPCServer
//
//  Created by Yuki Takei on 2016/11/29.
//
//

import Foundation

let PORT = UInt(ProcessInfo.processInfo.environment["PORT"] ?? "8080") ?? 8080

// Connect redis with 10 connection pools
let redis = try Redis(poolSize: 10)

let server = try! HTTPServer { request, writer in
    var request = request
    
    do {
        // middleare section
        request = jsonParserMiddleware(request: request)
        
        // dispatch routes
        var response = dispatch(request: request)
        
        // prepare for response
        response.headers["Server"] = "Prorsum"
        if let _ = request.json {
            response.headers["Content-Type"] = "application/json"
        }
        
        try writer.serialize(response)
        
        writer.close()
        
        let method = "\(request.method)".uppercased()
        print("\(method) \(request.path ?? "/") \(response.statusCode)") //access log
    } catch {
        writer.close()
    }
}

try! server.bind(host: "0.0.0.0", port: PORT)
print("Server listening at 0.0.0.0:\(PORT)")
try! server.listen()
