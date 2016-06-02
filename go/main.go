package main

import (
	"github.com/valyala/fasthttp"
	"sync"
)

func main() {
	mutex := &sync.Mutex{}
	m := make(map[int][]byte)
	cnt := 0
	max := 250000

	handler := func(ctx *fasthttp.RequestCtx) {
		newBuffer := make([]byte, 1024)
		mutex.Lock()
		m[cnt] = newBuffer
		if cnt >= max {
			delete(m, cnt-max)
		}
		cnt = cnt + 1
		mutex.Unlock()
		ctx.WriteString("OK")
	}
	fasthttp.ListenAndServe(":8080", handler)
}
