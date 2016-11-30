//
//  Command.swift
//  TSSSJSONRPCServer
//
//  Created by Yuki Takei on 2016/12/01.
//
//

public enum RedisCommand: CustomStringConvertible {
    case SET(String, String)
    case APPEND(String, String)
    case BITCOUNT(String, Int, Int)
    case BITOP(String, String, Array<String>)
    case BITPOS(String, Int, Array<Int>)
    case INCR(String)
    case INCRBY(String, Int)
    case DECR(String)
    case DECRBY(String, Int)
    case GET(String)
    case GETBIT(String, Int)
    case SETBIT(String, Int, Int)
    case GETRANGE(String, Int, Int)
    case GETSET(String, String)
    case INCRBYFLOAT(String, Float)
    case MGET(Array<String>)
    case MSET(Array<(String, String)>)
    case MSETNX(Array<(String, String)>)
    case SETEX(String, Int, String)
    case PSETEX(String, Int, String)
    
    case SETNX(String, String)
    case SETRANGE(String, Int, String)
    case STRLEN(String)
    
    case DEL(Array<String>)
    case DUMP(String)
    case EXISTS(Array<String>)
    case EXPIRE(String, Int, Bool)
    
    case EXPIREAT(String, Double, Bool)
    
    case KEYS(String)
    case MOVE(String, Int)
    case PERSIST(String)
    case TTL(String, Bool)
    case RANDOMKEY
    case RENAME(String, String)
    case RENAMENX(String, String)
    case RESTORE(String, Int, String, Bool)
    case SORT(String, String)
    case TYPE(String)
    
    case BLPOP(Array<String>, Int)
    case BRPOP(Array<String>, Int)
    case BRPOPLPUSH(String, String, Int)
    case LINDEX(String, Int)
    case LINSERT(String, String, String, String)
    case LLEN(String)
    case LPOP(String)
    case LPUSH(String, Array<String>)
    case LPUSHX(String, String)
    case LRANGE(String, Int, Int)
    case LREM(String, Int, String)
    case LSET(String, Int, String)
    case LTRIM(String, Int, Int)
    case RPOP(String)
    case RPOPLPUSH(String, String)
    case RPUSH(String, Array<String>)
    case RPUSHX(String, String)
    
    case SADD(String, Array<String>)
    case SCARD(String)
    case SDIFF(Array<String>)
    case SDIFFSTORE(String, Array<String>)
    case SINTER(Array<String>)
    case SINTERSTORE(String, Array<String>)
    case SISMEMBER(String, String)
    case SMEMBERS(String)
    case SMOVE(String, String, String)
    case SPOP(String)
    case SRANDMEMBER(String, Int?)
    case SREM(String, Array<String>)
    case SUNION(Array<String>)
    case SUNIONSTORE(String, Array<String>)
    
    case ZADD(String, Dictionary<String, String>)
    case ZCARD(String)
    case ZCOUNT(String, String, String)
    case ZINCRBY(String, Float, String)
    
    case HSET(String, String, String)
    case HSETNX(String, String, String)
    case HDEL(String, Array<String>)
    case HEXISTS(String, String)
    case HGET(String, String)
    case HGETALL(String)
    case HINCRBY(String, String, Int)
    case HINCRBYFLOAT(String, String, Float)
    case HKEYS(String)
    case HLEN(String)
    case HMGET(String, Array<String>)
    case HMSET(String, Dictionary<String, String>)
    case HSTRLEN(String, String)
    case HVALS(String)
    
    case AUTH(String)
    case ECHO(String)
    case PING
    case SELECT(Int)
    
    case RAW([String])
}



extension RedisCommand {
    public var description: String {
        do {
            return try toArrayString().joined(separator: " ")
        } catch {
            return ""
        }
    }
    
    public var shouldKeepConnection: Bool {
        switch self {
        case .RAW(let command):
            if command.count == 0 {
                return false
            }
            return command[0].lowercased() == "subscribe"
        default:
            return false
        }
    }
    
    public func toArrayString() throws -> [String] {
        let cmd: [String]
        
        switch(self) {
        case .PING:
            cmd = ["PING"]
        case .SET(let key, let val):
            cmd = ["SET", key, val]
        case .GET(let key):
            cmd = ["GET", key]
        case .DEL(let keys):
            cmd = ["DEL"]+keys
        case .EXPIRE(let key, let ttl, let bool):
            cmd = ["EXPIRE", key, "\(ttl)", "\(bool)"]
        case .SETEX(let key, let ttl, let val):
            cmd = ["SETEX", key, "\(ttl)", val]
        case .PSETEX(let key, let ttl, let val):
            cmd = ["PSETEX", key, "\(ttl)", val]
        case .RAW(let command):
            cmd = command
        default:
            throw RedisError.unimplementedCommand
        }
        
        return cmd
    }
}
