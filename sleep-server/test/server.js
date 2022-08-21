/* eslint-env mocha */
const expect = require('chai').expect;
const rp = require('request-promise');
const sleepserver = require('../index.js');

describe('test sleep durations', () => {
  // start the server
  sleepserver.start(3600, function () {
    it('returns after 50ms', async () => {
      let startTime = new Date();
      let result = JSON.parse(await rp('http://localhost:3600/sleep/50'));
      let duration = (new Date()) - startTime;
      console.log(duration);
      expect(result.timeout).to.equal(50);
      expect(result.success).to.equal(true);
      expect(duration >= 45 && duration <= 100).to.equal(true);
    });

    it('returns after 1000ms', async () => {
      let startTime = new Date();
      let result = JSON.parse(await rp('http://localhost:3600/sleep/1000'));
      let duration = (new Date()) - startTime;
      console.log(duration);
      expect(result.timeout).to.equal(1000);
      expect(result.success).to.equal(true);
      expect(duration >= 990 && duration <= 1050).to.equal(true);
    });

    it('last test', async () => {
      setTimeout(() => {
        process.exit(0);
      }, 100);
    });
  });

  it('is true', () => {
    // somehow need this to make the test to run
    expect(true).to.equal(true);
  });
});
