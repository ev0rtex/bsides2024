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
