require('coffee-script/register');
var exports;

exports = module.exports = require("./service");

exports.Client = require("./client");

exports.RestAdapter = require("./adapters/rest");
