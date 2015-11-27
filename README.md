# ZeroMS
Build microservices with ZeroMQ.

Provides familiar express-style API as an abstraction of 0mq REQ/REP sockets for building REST-like microservice interfaces.

## Installation
You will need ZeroMQ installed: [Get ZeroMQ](http://zeromq.org/intro:get-the-software)

```sh
npm install zeroms
```
## Quickstart
Service:
```javascript
var ZM;

ZM = require('zeromicro');

var users, zms;
zms = new ZMS("tcp://0.0.0.0:5555");
zms.use(ZMS.restInterface);

users = zms.router("/users");
users.route("/findById", function(req, res, next) {
  return res.json({
    user: {
      id: req.params.id
    }
  });
});
zms.start()
```

Client:
```javascript
var Client, client;

Client = require('zeromicro').Client;

client = new Client("tcp://0.0.0.0:5555");

client.on('start', function() {
  var opts;

  opts = {
    params: {
      id: '4321'
    }
  };
  client.request('/users/findById', opts, function(err, resp) {
    return console.log(resp);
  });
});
```

## Examples
Examples are located in the github repo:
```sh
git clone git://github.com/chuej/zeroms.git
cd zeroms
npm install
```

### Docker / Docker Compose
The following command will start the example service, the the client.
```sh
docker-compose up example
```
### npm scripts
Service:
```sh
npm run-script example-service
```

Client:
```sh
npm run-script example-client
```

## Usage
```javascript
var ZM, startService;

ZM = require('zeromicro');

startService = function() {
  var templates, users, zms;
  zms = new ZMS("tcp://0.0.0.0:5555");
  zms.use(ZMS.restInterface);

  zms.use(function(req, res, next) {
    // middleware
    return next(null);
  });


  users = zms.router("/users");
  users.use(function(req, res, next) {
    // users specific middleware
    return next(null);
  });
  users.use(function(err, req, res, next) {
    // users specific error handler
    // calling next w/ error will continue on to service error handlers
    return next(err);
  });
  users.route("/findById", function(req, res, next) {
    return res.json({
      user: {
        id: req.params.id
      }
    });
  });
  users.route("/update", function(req, res, next) {
    res.setStatus(201);
    return res.json({
      user: {
        id: req.params.id
      }
    });
  });


  templates = zms.router("/templates");
  templates.route("/html", function(req, res, next) {
    return res.send("<html></html>");
  });


  zms.use(function(err, req, res, next) {
    // handler for errs generated in service
     //calling next w/ err will trigger default res.error
    return res.send("ERROR");
  });
  zms.on 'error', (err)->
    // handle uncaught service/router errors

  return zms.start();
};

startService();

```
```javascript
var Client, client;

Client = require('zeromicro').Client;

client = new Client("tcp://0.0.0.0:5555");

client.on('start', function() {
  var opts, resp, stream;

  opts = {
    params: {
      id: '1234'
    },
    body: {
      data: {
        hello: "world"
      }
    },
    headers: {
      method: 'PATCH'
    },
    copts: {
      timeout: 100000
    }
  };
  client.request('/users/update', opts, function(err, resp) {
    // resp is json
    return console.log(resp);
  });


  opts = {
    params: {
      id: '4321'
    }
  };
  client.request('/templates/html', opts, function(err, resp) {
    // resp is text
    return console.log(resp);
  });


  resp = '';
  stream = client.request('/users/findById', opts);
  stream.on('data', function(data) {
    return resp += data;
  });
  return stream.on('end', function() {
    // resp is stringified json
    return console.log(resp);
  });
});
```

## Tests
Running the test suite is as simple as cloning the repo and running ```npm test```.
```sh
git clone git://github.com/chuej/zeroms.git
cd zeroms
npm install
npm test
```
