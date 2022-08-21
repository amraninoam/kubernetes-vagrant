var http = require('http');

function start(port, callback) {
  function handleRequest(req, resp) {
    // console.log(req.url)
    if (req.url != null && req.url.startsWith('/sleep/')) {
      var timeout = parseInt(req.url.substring(7));
      var os = require("os");
      setTimeout(function () {
        resp.end(JSON.stringify({
          success: true,
          host: os.hostname(),
          timeout: timeout,
        }));
      }, timeout);
    } else {
      resp.statusCode = 200;
      var os = require("os");
      resp.end(os.hostname());
    }
  }

  var server = http.createServer(handleRequest);
  server.listen(port,'0.0.0.0', callback);
}

exports.start = start;
