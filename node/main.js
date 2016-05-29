function handler() {
  var d = new Map()
  var reqNo = 0;
  var TOTAL = 250000

  return function(req, res) {
    reqNo = reqNo + 1
    d.set(reqNo, Buffer.alloc(1024))
    if (reqNo >= TOTAL) {
      d.delete(reqNo - TOTAL)
    }
    res.end("OK");
  }
}

require('http').createServer(handler()).listen(8080)
