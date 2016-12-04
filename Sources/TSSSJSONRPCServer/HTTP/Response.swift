//
//  Response.swift
//  TSSSJSONRPCServer
//
//  Created by Yuki Takei on 2016/11/30.
//
//

import Foundation

extension Response {
    
    init(with response: JSONRPCV2.Response) {
        do {
            try self.init(status: .created, body: .buffer(response.toJSON().rawData()))
        } catch {
            self.init(status: .internalServerError)
        }
    }
    
    public var buffer: Data? {
        switch body {
        case .buffer(let data):
            return data
        default:
            return nil
        }
    }
}
