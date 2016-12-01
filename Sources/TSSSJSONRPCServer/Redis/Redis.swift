//
//  Redis.swift
//  TSSSJSONRPCServer
//
//  Created by Yuki Takei on 2016/11/30.
//
//

import CHiredis
import Foundation

public enum RedisError: Error {
    case unimplementedCommand
    case connectionFailed
    case rawError(String)
    case alreadyClosed
    case failedToGetConnectionFromPool
}

private final class RedisConnection {
    
    var isClosed = false
    
    var inUse = false
    
    let cond = Cond()
    
    let context: UnsafeMutablePointer<redisContext>
    
    public init(host: String, port: Int) throws {
        context = redisConnect(host, Int32(port))
        
        if context.pointee.err > 0 {
            let errorString = withUnsafePointer(to: &context.pointee.errstr.0) {
                String(cString: $0)
            }
            throw RedisError.rawError(errorString)
        }
    }
    
    func reserve(){
        cond.mutex.lock()
        inUse = true
        cond.mutex.unlock()
    }
    
    func release(){
        cond.mutex.lock()
        inUse = false
        cond.mutex.unlock()
    }
    
    func disconnect() {
        cond.mutex.lock()
        if !isClosed {
            isClosed = true
            redisFree(context)
        }
        cond.mutex.unlock()
    }
}

// A Thread safe Redis Client
public final class Redis {
    
    fileprivate var pool = [RedisConnection]()
    
    let cond = Cond()
    
    public init(host: String = "127.0.0.1", port: Int = 6379, poolSize: Int = 1) throws {
        for _ in 0..<poolSize {
            pool.append(try RedisConnection(host: host, port: port))
        }
    }
    
    /**
     * Take a free connection to query
     * This method blocks the thread until a free connection is available
     */
    fileprivate func getConnection(_ retryCount: Int = 0) throws -> RedisConnection {
        if Double(retryCount) > (0.1*10)*5 {
            throw RedisError.failedToGetConnectionFromPool
        }
        
        for p in pool {
            if p.inUse {
                continue
            }
            p.reserve()
            return p
        }
        
        cond.mutex.lock()
        _ = cond.wait(timeout: 0.1)
        cond.mutex.unlock()
        
        return try getConnection(retryCount+1)
    }
    
    /**
     * issue command to Redis
     */
    public func command(_ cmd: RedisCommand) throws -> [String] {
        cond.mutex.lock()
        defer {
            cond.mutex.unlock()
        }
        let con = try getConnection()
        
        if con.isClosed {
            con.release()
            throw RedisError.alreadyClosed
        }
        
        let cmdArray = try cmd.toArrayString()
        
        let replyRef = redisCommandArgv(
            con.context,
            Int32(cmdArray.count),
            UnsafeMutablePointer(mutating: cmdArray.map { ($0 as NSString).utf8String }),
            nil
        )
        
        con.release()
        
        defer {
            freeReplyObject(replyRef)
        }
        
        let reply = replyRef!.assumingMemoryBound(to: redisReply.self)
        
        let status = Int32(reply.pointee.integer)
        if status != REDIS_OK {
            throw RedisError.rawError(String(cString: reply.pointee.str))
        }
        
        if reply.pointee.type == REDIS_REPLY_ERROR {
            throw RedisError.rawError(String(cString: reply.pointee.str))
        }
        
        if reply.pointee.elements > 0 {
            var replies = [String]()
            for i in stride(from: 0, to: Int(reply.pointee.elements), by: 1) {
                guard let element = reply.pointee.element[i] else {
                    continue
                }
                
                if element.pointee.type == REDIS_REPLY_ERROR {
                    throw RedisError.rawError(String(cString: reply.pointee.str))
                }
                replies.append(String(cString: element.pointee.str))
            }
            
            return replies
        }
        
        return [String(cString: reply.pointee.str)]
    }
    
    public func disconnect() {
        cond.mutex.lock()
        for p in pool {
            p.disconnect()
        }
        cond.mutex.unlock()
    }
    
}
