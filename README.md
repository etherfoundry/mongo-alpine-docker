# docker-mongo-alpine
This is a MongoDB image that can serve as both primary and secondary nodes in a replica set. It is based heavily on the official Mongo Dockerfile.

The containers must be started with '--replSet' option specified. I am using this within Docker Swarm.

For your initial Primary node:
- Specify an environment variable of RS_INIT=yes
 - This causes the node to call rs.initiate() with itself as the only member.
- The name of this node for the initiate() call is specified via the 'RSHOST' env variable.
 - RSHOST defaults to a value of 'mongo'. This name must resolve via DNS for all nodes.
- List replica set members as a comma separated string in the RS_MEMBERS variable. (e.g. RS_MEMBERS=rs1,rs2,rs3
 - The Primary node will automatically call rs.add() on each of these RS_MEMBERS, if present. Currently there is no support for using non-default/27017 ports.

On your replica nodes:
- Specify an environment variable of RS_REGISTER=yes
 - This causes the container to run mongo-cli on start, to invoke rs.add() on HOST (default 'mongo').
 - You should specify MEMBER_NAME as the resolvable hostname used for the rs.add() invocation above. Else, it will use HOSTNAME, which defaults to the container's ID, which may not resolve, and, if it does, you will end up with unreachable containers in your RS configuration as nodes are replaced.

Otherwise, this container is based pretty heavily on the official mongodb image. Thus, usage is the same, and you should consider the typical bindings for volumes (/data/db and /data/configdb). See the official repository for additional documentation

Feel free to comment if you encounter any problems with use or if you have suggestions for changes to the image.


Published at https://hub.docker.com/r/garrettboast/mongo/ , intended for Docker Swarm.

by [Garrett Boast](http://garrettboast.com)
