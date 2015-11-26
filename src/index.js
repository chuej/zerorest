require('coffee-script/register');
var exports;

exports = module.exports = require("./service");

exports.Client = require("./client");

exports.restAdapter = require("./adapters/rest");
