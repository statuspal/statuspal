<h1>
  Statuspal
  <a href="https://circleci.com/gh/statuspal/statuspal">
    <img src="https://circleci.com/gh/statuspal/statuspal.svg?style=svg&circle-token=be2ef35b5c8c04eccfab6ed9dea500b82eb41abf" alt="CircleCI Build Status" align="right" />
  </a>
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

You can run Statuspal on your own server easily thanks to a Docker setup, it will
create a PostgreSQL container and another one with Statuspal for you.

Git clone the project and under the root directory run:

1. `cp .env_template .env` and fill the required environment variables in `.env`
2. `./docker/build.sh` (This can take a while, but after the first time it should be quick)
3. `./docker/start.sh` to start the server, then you should be able to access
it under http://localhost:5000/admin, sign in with the default user provided in
the terminal and change its password and email.
