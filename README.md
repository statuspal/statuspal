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

Run `mix phx.server`

## Self hosted CE

1. docker-compose -f docker/docker-compose.yml build
2. docker-compose -f docker/docker-compose.yml run statushq /statushq/setup.sh
3. docker-compose -f docker/docker-compose.yml up statushq
