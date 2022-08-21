#!/usr/bin/env node

var sleepserver = require('./index.js');

// console.log(process.argv)
if (process.argv.length < 3) {
  console.log('usage: sleep-server <port>');
} else {
  let port = parseInt(process.argv[2]);
  sleepserver.start(port, function () {
    console.log('listening on http://localhost:%s', port);
  });
}
