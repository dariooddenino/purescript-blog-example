'use strict';

const Hapi = require('hapi');
const Path = require('path');

const server = new Hapi.Server();

server.connection({ port: 3000 });

let posts = [
  {
    id: 1,
    title: 'Post 1',
    body: 'This is Post n.1'
  },
  {
    id: 2,
    title: 'Post 2',
    body: 'This is Post n.2'
  }
];

var generateNextId = function(generateNextId) {
  let ids = posts.map((p) => {
    return p.id;
  });

  return Math.max.apply(Math, ids) + 1;
}

server.register(require('inert'), (err) => {
  if (err) {
    throw err;
  }

  server.route({
    method: 'GET',
    path: '/app.js',
    handler: {
      file: Path.join(__dirname, 'public', 'app.js')
    }
  });

  server.route({
    method: 'GET',
    path: '/{p*}',
    handler: {
      file: Path.join(__dirname, 'public', 'index.html')
    }
  });

  server.route({
    method: 'GET',
    path: '/api/posts',
    handler: function (req, reply) {
      return reply(posts);
    }
  });

  server.route({
    method: 'GET',
    path: '/api/posts/{id}',
    handler: function (req, reply) {
        let post = posts.filter((p) => {
          return p.id === req.params.id;
        })[0];

        if (post) {
          return reply(post);
        }
        return reply('Post not found').code(404);
    }
  });

  server.route({
    method: 'POST',
    path: '/api/posts',
    handler: function (req, reply) {
      var newPost = {
        id: generateNextId(),
        title: req.payload.title,
        body: req.payload.body
      };
      posts.push(newPost);
      return reply(newPost);
    }
  });

  server.route({
    method: 'DELETE',
    path: '/api/posts/{id}',
    handler: function (req, reply) {
      posts = posts.filter((p) => {
        return p.id !== req.params.id;
      });
      return reply(true);
    }
  });

  server.route({
    method: 'PUT',
    path: '/api/posts/{id}',
    handler: function (req, reply) {
      let modified;
      posts.map((p) => {
        if (p.id === req.params.id) {
          p.title = req.payload.title;
          p.body = req.payload.body;
          modified = p;
        }
        return p;
      });
      if (modified) {
        return reply(modified);
      }
      return reply('Post not found').code(404);
    }
  });

  server.start((err) => {
    if (err) {
      throw err;
    }

    console.log('Server running at:', server.info.uri);
  });
});
