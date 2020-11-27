# Connects two networks with an own router each

The following picture describes the initial setup of two separate networks with a server running. [proj1.tf](./proj1.tf) and [proj2.tf](./proj2.tf) represent this state.

```
                   ~~~~~~~~
                 /          \
                |  Internet  |
                 \          /
                   ~~~~~~~~
                 /          \
       +-----------+        +-----------+
       | Router    |        | Router    |
       +-----------+        +-----------+
       | 10.10.1.1 |        | 10.10.2.1 |
       +-----------+        +-----------+
             |                    |
        ~~~~~~~~~~            ~~~~~~~~~~
      /            \        /            \
     | Net Proj 1   |      | Net Proj 2   |
     | 10.10.1.0/24 |      | 10.10.2.0/24 |
      \            /        \            /
        ~~~~~~~~~~            ~~~~~~~~~~
             |                     |
     +------------+          +------------+
     | Server 1   |          | Server 2   |
     +------------+          +------------+
     | 10.10.1.15 |          | 10.10.2.29 |
     +------------+          +------------+
```

The task at hand is: How could we configure the setup so that Server 1 and Server 2 are able to communicate.

Constraints:
* no floating ips involved
* no need for additional routes on compute nodes
* each stack must be treated as unit

My idea would be to introduce a third stack that (by design/definition) is allowed to depend on both other stacks. Represented in [transfer.tf](./transfer.tf).
[transfer.tf](./transfer.tf) creates another network serving as a transfer network between both routers. Additionally it sets static routes with the other router as next hop.
I defined `10.0.0.0/30` to be our transfer net (but you could use any size). Each router gets a port from this network assigned to it.

```
                   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                 /                                                       \
                |                       Internet                          |
                 \                                                       /
                   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                 /                                                       \
       +---------------------------+         ~~~~~~~~~~        +---------------------------+
       | Router                    |       /            \      | Router                    |
       +---------------------------+      | Transfer     |     +---------------------------+
       | 10.0.0.1                  |------| 10.0.0.0/30  |-----| 10.0.0.2                  |
       | 10.10.1.1                 |       \            /      | 10.10.2.1                 |
       +---------------------------+         ~~~~~~~~~~        +---------------------------+
       | 10.10.2.0/24 via 10.0.0.2 |                           | 10.10.1.0/24 via 10.0.0.1 |
       +---------------------------+                           +---------------------------+
             |                                                               |
        ~~~~~~~~~~                                                       ~~~~~~~~~~
      /            \                                                   /            \
     | Net Proj 1   |                                                 | Net Proj 2   |
     | 10.10.1.0/24 |                                                 | 10.10.2.0/24 |
      \            /                                                   \            /
        ~~~~~~~~~~                                                       ~~~~~~~~~~
             |                                                               |
     +------------+                                                     +------------+
     | Server 1   |                                                     | Server 2   |
     +------------+                                                     +------------+
     | 10.10.1.15 |                                                     | 10.10.2.29 |
     +------------+                                                     +------------+
```

As a result, we kan keep both routers, so each stack is isolated in terms of is deployable on its own. Because the routers are default gateways for compute nodes anyways, there is no need to distribute any additional routes.
