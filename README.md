octocluster
=============

A set of [Serf](http://www.serfdom.io/) event handlers that helps:

1. A distributed HTTP and websocket proxy like [Hipache](https://github.com/dotcloud/hipache) provide HTTP router services to.
2. An arbitrary amount of [Docker](http://www.docker.io/) based [octohost](http://www.octohost.io/) servers.

Usage
=========

1. Start up your [octorouter](https://github.com/octohost/octorouter) and point your wildcard dns to it.
2. Start up at least two [octohosts](http://www.octohost.io/).
3. Make sure they've all joined the same Serf cluster - the octorouter should have the role of 'router' and the octohosts should be set to the 'host' role.
4. As the octohost servers receive a git push with website code, they:
   1. Build the container described in the Dockerfile.
   2. Launch the container with a local and transient domain name.
   3. Register with the octorouter - who then routes the HTTP requests to that particular container on that particular octohost.
5. Profit.

This was built so that more than a single octohost server could be used with the same domain name.

TODO
=========

1. Proper health checking.
2. Move sites from one octohost to another.
3. Get container statistics from octorouter logs.
4. Use encrypted Serf network.