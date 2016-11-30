//
//  Request.swift
//  TSSSJSONRPCServer
//
//  Created by Yuki Takei on 2016/11/30.
//
//

extension Request {
    var json: JSON? {
        get {
            return storage["json"] as? JSON
        }
        set {
            storage["json"] = newValue
        }
    }
}
