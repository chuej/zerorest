# ZeroREST
Build microservices with ZeroMQ.

Provides familiar express-style API as an abstraction of 0mq REQ/REP sockets for building REST-like microservices.

## Installation
You will need ZeroMQ installed: [Get ZeroMQ](http://zeromq.org/intro:get-the-software)

```sh
npm install zerorest
```

## Quickstart
Service:
```javascript
var ZR;

ZR = require('zerorest');

var users, zms;
zms = new ZR("tcp://0.0.0.0:5555");

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

Client = require('zerorest').Client;

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
git clone git://github.com/chuej/zerorest.git
cd zerorest
npm install
```

### Docker / Docker Compose
The following command will start the example service, the the client.
```sh
docker-compose up example
```
### sh scripts
Service:
```sh
./bin/example-service
```

Client:
```sh
./bin/example-client
```

## Usage
```javascript
var ZR, startService;

ZR = require('zerorest');

startService = function() {
  var templates, users, zms;
  conf = {
    broker: {
      concurrency: 5,  // number of concurrent router sockets
      hearbeat: 2500,
      lbmode: 'rr' // load-balance mode: round-robin (rr) or random (rand)
    },
    router: {
      concurrency: 5, // number of concurrent dealer sockets per route
      reconnect: 1000,
      heartbeat: 2500
    },
    url: "tcp://0.0.0.0:5555"
  };
  zms = new ZR("tcp://0.0.0.0:5555");
  // or
  zms = new ZR(conf);


  zms.use(function(req, res, next) {
    // middleware
    return next(null);
  });

  // array of middleware
  zms.use([function(req,res,next){ return next(null); }]);

  conf = {
    concurrency: 5, // number of concurrent dealer sockets per route
    reconnect: 1000,
    heartbeat: 2500,
    path: "/users"
  };

  users = zms.router("/users");
  // or
  users = zms.router(conf);
  
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
        link: {
          path: '/findById'
          params: {
            id: req.params.id
          }
        }
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
  zms.on('error', function(err) {
    // handle uncaught service/router errors
  });
  return zms.start();
};

startService();

```
```javascript
var Client, client;

Client = require('zerorest').Client;

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
git clone git://github.com/chuej/zerorest.git
cd zerorest
npm install
npm test
```

## Resources
- [Why You Should Start Using Microservices](https://blog.risingstack.com/why-you-should-start-using-microservices/)
- [ZeroMQ instead of HTTP, for internal services | Hacker News](https://news.ycombinator.com/item?id=6086983)
