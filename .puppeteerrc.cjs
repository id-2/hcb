const {join} = require('path');

/**
 * @type {import("puppeteer").Configuration}
 */
module.exports = {
  executablePath: process.env.PUPPETEER_EXECUTABLE_PATH,
};