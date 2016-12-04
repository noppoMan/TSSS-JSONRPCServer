//
//  app.swift
//  TSSSJSONRPCServer
//
//  Created by Yuki Takei on 2016/12/01.
//
//

@_exported import Prorsum
@_exported import SwiftyJSONRPC


func jsonRPCResponder(_ request: Request) throws -> Response {
    guard let json = request.json, !json.isEmpty else {
        throw JSONRPCV2Error.parseError
    }
    
    let rpcRequest = JSONRPCV2.Request(json: json)
    
    var rpcResponseItems: [JSONRPCV2.ResponseItem] = []
    for req in rpcRequest.items {
        if let error = req.error {
            rpcResponseItems.append(JSONRPCV2.ResponseItem(id: req.id, error: error))
        } else {
            switch req.method! {
            case "getWizards":
                let result = getWizards()
                rpcResponseItems.append(JSONRPCV2.ResponseItem(id: req.id, result: JSON(result)))
                
            case "redisPing":
                if let count = req.params?.int {
                    let result = redisPing(count)
                    rpcResponseItems.append(JSONRPCV2.ResponseItem(id: req.id, result: JSON(result)))
                }
                else {
                    rpcResponseItems.append(JSONRPCV2.ResponseItem(id: req.id, error: JSONRPCV2Error.invalidParams))
                }
                
            case "plzLGTMImage":
                do {
                    rpcResponseItems.append(JSONRPCV2.ResponseItem(id: req.id, result: JSON(try plzLGTMImage())))
                } catch {
                    rpcResponseItems.append(JSONRPCV2.ResponseItem(id: req.id, error: .serverError))
                }
                
            default:
                rpcResponseItems.append(JSONRPCV2.ResponseItem(id: req.id, error: .methodNotFound))
            }
        }
    }
    
    let rpcResponse = JSONRPCV2.Response(isBatch: rpcRequest.isBatch, items: rpcResponseItems)
    
    return Response(with: rpcResponse)
}

func jsonParserMiddleware(request: Request) -> Request {
    var request = request
    if let cType = request.contentType {
        switch (cType.type, cType.subtype) {
        case ("application", "json"):
            if case .buffer(let data) = request.body {
                request.json = JSON(data: data)
            }
        default:
            break
        }
    }
    
    return request
}

func dispatch(request: Request) -> Response {
    do {
        switch (request.path ?? "/", request.method) {
        case ("/jsonrpc", .post):
            return try jsonRPCResponder(request)
        default:
            return Response(status: .notFound, body: .buffer("{\"message\": \"404, Not found\"}".data))
        }
    } catch {
        print("\(error)")
        return Response(status: .internalServerError, body: .buffer("{\"message\": \"500, Internal Server Error\"}".data))
    }
}
