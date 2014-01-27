octocluster - in progress
=============

A set of [Serf](http://www.serfdom.io/) event handlers that helps:

1. A distributed HTTP and websocket proxy like [Hipache](https://github.com/dotcloud/hipache) provide HTTP router services to.
2. An arbitrary amount of [Docker](http://www.docker.io/) based [octohost](http://www.octohost.io/) servers.

Usage
=========

1. Start up your [octorouter](https://github.com/octohost/octorouter) and point your wildcard dns to it.
2. Start up at least two [octohosts](http://www.octohost.io/).
3. Make sure they've all joined the same Serf cluster - the octorouter should have the role of 'router' and the octohosts should be set to the 'host' role.
4. Need to have proper dns or xip.io domain names.
5. As the octohost servers receive a git push with website code, they:
   1. Build the container described in the Dockerfile.
   2. Launch the container with all domain names needed - including the local IP based one.
   3. Register with the octorouter - who then routes the HTTP requests to that particular container on that particular octohost. (Not done.)

This was built so that more than a single octohost server could be used with the same domain name.

TODO
=========

1. Proper health checking.
2. Move sites from one octohost to another.
3. Get container statistics from octorouter logs.
4. Use encrypted Serf network.
5. SSH encryption for git clone.

Example Serf Event
=========

```
serf event addroute https://github.com/darron/basic-handbill-test.git,host1,http://host1.54.184.66.88.xip.io/
serf event addroute https://github.com/darron/basic-handbill-test2.git,host2,http://host2.54.184.101.227.xip.io/
```

Setup
========

On the router:

```
git clone https://github.com/octohost/octocluster.git /etc/serf/handlers
echo "ROLE=router" > /etc/serf/role
# Change the domain name in /etc/serf/handlers/addroute.sh
service serf restart
```

On the other boxes:

```
serf join xx.xx.xx.xx
```