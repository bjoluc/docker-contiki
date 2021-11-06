# docker-contiki

[Contiki](https://github.com/contiki-os/contiki) Docker image for a university course on networked embedded systems. Supports msp430 (only) and simulations via Cooja.

## How to use this

Install [docker](https://docs.docker.com/get-docker/) and [docker-compose](https://docs.docker.com/compose/).
Afterwards, download [docker-compose.yml](/docker-compose.yml) from this repo and create a `src` directory next to it.
Then run `docker-compose up -d` to start the `contiki` container.

### On Linux

When you run `docker-compose exec contiki cooja`, the Cooja GUI should open up.
The host's `src` directory is mounted into `/home/user/src`.
To run a shell in the container, issue `docker-compose exec contiki bash`.

### On anything that doesn't natively support X11

You may be able to use SSH with X Forwarding to access the Cooja GUI:

* From your host machine, ssh into the `contiki` container via `ssh -X user@localhost -p 2222` (the password is `user`)
* Via ssh, run `cooja` in the container
