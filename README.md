# Statuspal

## Local development

### Dependencies

1. Elixir ~> 1.5.1
2. Node.js >= 6
3. Yarn
4. PostgreSQL

### Setup

Run `./dev_setup.sh`

### Run locally

Run `mix phx.server` and the server should be running at `http://localhost:4000`.

## Self hosted Statuspal

You can run Statuspal on your own server easily thanks to a Docker setup, it will create a PostgreSQL container and another one with Statuspal for you.

Git clone the project and under the root directoy:

1. Run `cp .env_template .env` and fill all the environment variables in `.env`
2. Run `docker-compose -f docker/docker-compose.yml build` (This will take a few minutes, but after the first time it should be quick)
3. Run `docker-compose -f docker/docker-compose.yml run statushq /statushq/setup.sh` to setup the container with a default user.
4. Run `docker-compose -f docker/docker-compose.yml up statushq` to start the container, then you should be able to access the server under `http://localhost:5000`.
