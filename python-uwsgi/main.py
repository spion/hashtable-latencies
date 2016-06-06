
storage = {}
request_no = 0
total_requests = 250000

headers = []
headers.append(('Connection', 'close'))
headers.append(('Content-Type', 'text/plain'))
# headers.append(('Content-Length', '2')) - borks wrk2

def application(env, start_response):
    global request_no
    request_no += 1
    storage[request_no] = bytearray(1024)
    if request_no > total_requests:
        del storage[request_no - total_requests]

    start_response('200 OK', headers)
    return [b"ok"]
