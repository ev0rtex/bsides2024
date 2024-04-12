Demo for BSidesSLC 2024
=======================

This creates a simple PostgreSQL database, a single-node vault instance with autounseal enabled, and then runs setup tasks to enable the PG database secrets engine for dynamic credential management.

To run it just make sure you have Docker installed and run:
```sh
docker compose up -d
```

Then you can make sure everything seems like it worked right with:
```sh
docker compose logs
```

Once it's all up and running you can fetch some credentials for DB access like so:
```sh
docker compose run --rm -it setup vault read database/creds/bsides-role
```
which will show something like this:
```
Key                  Value
---                  -----
token                hvs.DHgoO8o7FYCXk36dinu4Wou1
token_accessor       YrAGK20hf2QWfyywNhHZUyLd
token_duration       °
token_renewable      false
token_policies       ["root"]
identity_policies    []
policies             ["root"]
Key                Value
---                -----
lease_id           database/creds/bsides-role/e7Hd9j5lVnBeMokeoo3E1oEW
lease_duration     1h
lease_renewable    true
password           ZS9sTBieNfNk-wB6G2D2
username           v-root-bsides-r-eooVhF09EM7QviHHVGwC-1712943416
```

Now you can test logging into the database with those credentials:
```sh
# Attempt to log in with the above username
$ docker compose run --rm -it setup sh -c 'unset PGPASSWORD; psql -U v-root-bsides-r-eooVhF09EM7QviHHVGwC-1712943416'
Password for user v-root-bsides-r-eooVhF09EM7QviHHVGwC-1712943416:
psql (15.6, server 16.2)
WARNING: psql major version 15, server major version 16.
         Some psql features might not work.
Type "help" for help.

bsides=> \du
                                                      List of roles
                    Role name                    |                         Attributes                         | Member of
-------------------------------------------------+------------------------------------------------------------+-----------
 postgres                                        | Superuser, Create role, Create DB, Replication, Bypass RLS | {}
 v-root-bsides-r-eooVhF09EM7QviHHVGwC-1712943416 | Password valid until 2024-04-12 18:39:11+00                | {}

bsides=> \q
```
