package main

import (
	"io"
	"net/http"
	"runtime"
	"sync"
)

func main() {
	mutex := &sync.Mutex{}
	runtime.GOMAXPROCS(runtime.NumCPU())
	m := make(map[int][]byte)
	cnt := 0
	max := 250000

	handler := func(w http.ResponseWriter, r *http.Request) {
		mutex.Lock()
		m[cnt] = make([]byte, 1024)
		if cnt > max {
			m[cnt-max] = nil
		}
		cnt = cnt + 1
		mutex.Unlock()
		io.WriteString(w, "OK")
	}
	http.HandleFunc("/", handler)
	http.ListenAndServe(":8080", nil)
}
