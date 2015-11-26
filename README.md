# ZeroMS
Build microservices with ZeroMQ
## Usage
```javascript
var ZM, startService;

ZM = require('zeromicro');

startService = function() {
  var templates, users, zms;
  zms = new ZMS("tcp://0.0.0.0:5555");
  zms.use(ZMS.restAdapter);

  zms.use(function(req, res, next) {
    // middleware
    return next(null);
  });


  users = zms.master("/users");
  users.use(function(req, res, next) {
    // users specific middleware
    return next(null);
  });
  users.use(function(err, req, res, next) {
    // users specific error handler
    // calling next w/ error will continue on to service error handlers
    return next(err);
  });
  users.worker("/findById", function(req, res, next) {
    return res.json({
      user: {
        id: req.params.id
      }
    });
  });
  users.worker("/update", function(req, res, next) {
    res.setStatus(201);
    return res.json({
      user: {
        id: req.params.id
      }
    });
  });


  templates = zms.master("/templates");
  templates.worker("/html", function(req, res, next) {
    return res.send("<html></html>");
  });


  zms.use(function(err, req, res, next) {
    // error handler
     //calling next w/ err will trigger default res.error
    return res.send("ERROR");
  });
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
