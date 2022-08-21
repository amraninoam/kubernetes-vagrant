# sleep-server
[![NPM](https://nodei.co/npm/sleep-server.png)](https://npmjs.org/package/sleep-server)

Emulates a server that has variable response time.


## Purpose

Sometimes when I encounter a web server with slow response time, I would like to know whether the underlying database/resource server is slow, or there is an issue with my web server setup. This is especially true when dealing with Microsoft IIS + ASP.Net, which has issues dealing with too many threads in default configuration.

`sleep-server` acts as a dummy database/resource server, with a well defined response time, so you can determine the performance characteristic of your web server under load.


## Usage

`npm install sleep-server -g`

Start server on port 3600:

    sleep-server 3600

Test it. Type the following in browser:

    http://localhost:3600/sleep/1000

The sleep-server will respond after 1000 ms, as requested by `/sleep/1000`


## Load testing with sleep-client

Now the server is running, we can test it using sleep-client, which came in the same package.

Open another terminal or command prompt, and type

    sleep-client http://localhost:3600/sleep/5000

It should run for about 10 seconds, periodically reporting back the average response time. An efficient server should have the average response time very close to 5000ms.


## Load testing with sample proxy server

We are going to create a simple proxy server that sits between `sleep-server` and `sleep-client`. We will see how much latency this extra layer of indirection introduces.

First make sure your sleep-server is still running on port 3600. Then create the following testsleep.js script on a convenient directory:

```js
var http = require('http')
var port = 3800
var url = 'http://localhost:3600/sleep/5000'

function handleRequest(req, resp) {
    function callback(response) {
        var str = ''
        response.on('data', function (chunk) { str += chunk })
        response.on('end', function () { resp.end(str) })
    }
    http.request(url, callback).end()
}

var server = http.createServer(handleRequest)
server.listen(port, function() {
    console.log("listening on port " + port)
})
```

Go to that directory, and run `node testsleep.js`. It should run a simple server that would proxy all requests to `http://localhost:3600/sleep/5000`.

Run your sleep-client again, but this time hit the proxy server instead:

`sleep-client http://localhost:3800`

On my machine, the average response time is around 5002ms, which means the proxy server only adds 1ms latency.


## Load testing your web server

If your perform the above experiment using ASP.Net without `async` on an IIS server, you would get terrible result because the server would start to slow down when it hits thread limit. Or if your microservice infrastructure involves forwarding each request through multiple API nodes, you might want to know how much latency is introduced. Simply use `sleep-server` as the final node on the microservice chain, and create some simple mock services to sit in front of it. Now load test the chain and see how much latency is introduced.

