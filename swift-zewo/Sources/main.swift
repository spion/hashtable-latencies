import Foundation
import HTTPServer
import Router

var reqNo = 0;
var MAX = 250000;

var dataBytes = [Int: [Byte]]()

let app = Router { route in
    route.get("/") { _ in
        reqNo = reqNo + 1
        dataBytes[reqNo] = [Byte](repeating: 25, count: 1024)
        if (reqNo >= MAX) {
            dataBytes.removeValue(forKey: reqNo - MAX)
        }
        return Response(body: "OK")
    }
}

try Server(app).start()
