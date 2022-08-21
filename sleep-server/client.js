#!/usr/bin/env node

var http = require('http');

if (process.argv.length < 3) {
  console.log('usage: sleep-client <url> [requests per second] [duration in seconds]');
  console.log('e.g. : sleep-client http://localhost:3600/sleep/5000');
} else {
  var url = process.argv[2];
  var reqPerSec = process.argv.length > 3 ? parseInt(process.argv[3]) : 100;
  var duration = process.argv.length > 4 ? parseInt(process.argv[4]) : 10;
  var repeats = Math.floor(duration * reqPerSec);
  var concurrency;
  var delay;
  if (reqPerSec <= 100) {
    concurrency = 1;
    delay = 1000 / reqPerSec;
  } else if (reqPerSec <= 1000) {
    concurrency = 10;
    delay = 10000 / reqPerSec;
  } else if (reqPerSec <= 10000) {
    concurrency = Math.floor(reqPerSec / 100);
    delay = 10;
  } else {
    throw new Error('Only supports up to 10000 requests per seconds');
  }

  var times = [];
  var totaltime = 0;
  var totalRequests = 0;
  var totalReturns = 0;
  var totalLength = 0;

  var keepAliveAgent = new http.Agent({ keepAlive: true });
  var options = {
    agent: keepAliveAgent,
  };

  function request() { // eslint-disable-line
    if (totalRequests >= repeats) return null;
    totalRequests += 1;
    if (totalRequests < repeats) setTimeout(request, delay);

    var starttime = new Date();
    function callback(response) { // eslint-disable-line
      var responseString = '';
      response.on('data', function (data) {
        responseString += data;
      });
      response.on('end', function () {
        totalLength += responseString.length;
        totalReturns += 1;

        var endtime = new Date();
        var responsetime = (endtime - starttime);
        // if (typeof responsetime !== 'number') throw new Error('not a number');
        times.push(responsetime);
        totaltime += responsetime;
  
        // if (totalReturns % 100 === 0) {
        //   console.log('average time = ' + (totaltime / totalReturns) + 'ms');
        // }
        // only show final stats if more than 20 repeats (so we get enough data points, and also the percentiles indexer might be wrong otherwise)
        // show stats when done
        if (totalReturns >= repeats && repeats >= 100) {
          times.sort(function (a, b) { return a - b; });
          console.log('-----------------');
          console.log('total requested: ' + totalRequests);
          console.log('total returned: ' + totalReturns);
          console.log('total length: ' + totalLength);
          console.log('max: ' + times[totalReturns-1] + 'ms');
          console.log('98%: ' + times[Math.ceil(totalReturns * 0.98)-1] + 'ms');
          console.log('90%: ' + times[Math.ceil(totalReturns * 0.9)-1] + 'ms');
          console.log('75%: ' + times[Math.ceil(totalReturns * 0.75)-1] + 'ms');
          console.log('min: ' + times[0] + 'ms');
        }
      });
      // console.log('got something')
    }

    http.request(url, options, callback).end();
  }

  for (var thread = 0; thread < concurrency; thread++) request();

  var statusTimer = setInterval(function () {
    if (totalReturns >= repeats) {
      clearInterval(statusTimer);
    } else {
      console.log('average time = ' + (totaltime / totalReturns) + 'ms');
    }
  }, 1500);
}
