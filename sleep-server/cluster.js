#!/usr/bin/env node

var cluster = require('cluster');

if (process.argv.length < 4) {
  console.log('usage: sleep-server-cluster <port> <clusterSize>');
} else {
  var clusterSize = parseInt(process.argv[3]);

  function forkProcess() {
    let worker = cluster.fork();
  }

  if (cluster.isMaster) {
    console.log(`Master ${process.pid} is running`);

    // Fork workers.
    for (let i = 0; i < clusterSize; i++) {
      forkProcess();
    }
  } else {
    require('./server');
    console.log(`Worker ${process.pid} started`);
  }
}
