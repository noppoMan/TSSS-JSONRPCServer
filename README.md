# TSSS-JSONRPCServer

This is a tiny implementation of JSON RPC Server to be used in Tokyo Server Side Meetup#5 session.

**Event URL**: https://tokyo-ss-swift.connpass.com/event/46130/  
**Twitter Hash Tag**: #tsss

## Features
- [x] Minimal and fast
- [x] Event Driven master + multithreading request handlers Model(solving C10K)
- [x] Go style Councurrent System (Powerded by [noppoMan/Prorsum](https://github.com/noppoMan/Prorsum))
- [x] Thread Safe Redis Client
- [x] Fully supporting [JSON-RPC 2.0](http://www.jsonrpc.org/specification) Parser/Serializer (Powerded by [noppoMan/SwiftyJSONRPC](https://github.com/noppoMan/SwiftyJSONRPC))

## Getting Started

## Starting with Xcode

```sh
$ brew install hiredis
$ swift package generate-xcodeproj --type executable \
  -Xlinker -L/usr/local/lib \
  -Xcc -I/usr/local/include

$ open *.xcodeproj
```

## Starting with CLI

### Build
```sh
$ swift build
```

### Start up the server
```sh
$ ./build/debug/TSSSJSONRPCServer
# Server listening at 0.0.0.0:3000
```

### Functions
- `getWizards -> [String]`: List Harry Potter's wizards
- `redisPing(count: Int) -> [String]`: Issue Ping command to redis n(count) times
- `plzLGTMImage -> [String: String]`: Take a LGTM Image URL from http://www.lgtm.in


## LICENSE

TSSS-JSONRPCServer is released under the MIT license. See LICENSE for details.
