<h1>
  Statuspal
  [![CircleCI Buld Status](https://circleci.com/gh/messutied/statuspal.svg?style=svg&circle-token=be2ef35b5c8c04eccfab6ed9dea500b82eb41abf)](https://circleci.com/gh/messutied/statuspal)
</h1>

## Local development

### Dependencies

1. Elixir ~> 1.5.1
2. Node.js >= 6
3. Yarn
4. PostgreSQL
5. Imagemagick

### Setup

Run `./dev_setup.sh`

After this make sure `apps/statushq/config/dev.exs` has your proper DB configurations
(in general it should work as is) and place your API keys for Twitter and Mailgun in
`apps/statushq/config/dev.secret.exs`.

### Run locally

Run `mix phx.server` and the server should be running at `http://localhost:4000`.

## Self hosted Statuspal

You can run Statuspal on your own server easily thanks to a Docker setup, it will create a PostgreSQL container and another one with Statuspal for you.

Git clone the project and under the root directoy:

1. Run `cp .env_template .env` and fill all the environment variables in `.env`
2. Run `docker-compose -f docker/docker-compose.yml build` (This will take a few
  minutes, but after the first time it should be quick)
3. Run `docker-compose -f docker/docker-compose.yml run statushq /statushq/setup.sh`
to setup the container with a default user (only needed the first time).
4. Run `docker-compose -f docker/docker-compose.yml up statushq` to start the
container, then you should be able to access the server under `http://localhost:5000`.

If you ever change and environment variable inside of `.env` you'll need to run
`docker-compose -f docker/docker-compose.yml build` again and restart your container.
