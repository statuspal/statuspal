FROM ubuntu:16.04

LABEL maintainer="Eduardo Messuti <messuti.edd@gmail.com>"\
  description="Statushq self hosted"

ENV DEBIAN_FRONTEND noninteractive

# Base deps
RUN apt-get update; apt-get install -y --no-install-recommends apt-utils;\
    apt-get install -y curl wget locales vim git build-essential postgresql-client

# Set locales
RUN locale-gen en_US.UTF-8;\
    echo "export LANG=en_US.UTF-8" >> ~/.profile;\
    echo "locale-gen en_US.UTF-8" >> ~/.profile
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Install NodeJS
RUN (curl -sL https://deb.nodesource.com/setup_6.x | bash -);\
    apt-get install -y nodejs

# Install yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -;\
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list;\
    apt-get update && apt-get install -y yarn

# Install Elixir
RUN wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb; dpkg -i erlang-solutions_1.0_all.deb;\
    apt-get update; apt-get install -y esl-erlang elixir

RUN apt-get install -y imagemagick

####### Statushq CE

# Arguments/Env
ARG HOST
ARG PORT
ARG SECRET_KEY_BASE
ARG MG_DOMAIN
ARG MG_API_KEY
ARG TWITTER_CONSUMER_KEY
ARG TWITTER_CONSUMER_SECRET
ENV MIX_ENV prod

# RUN cd /; git clone https://gitlab.com/messutied/statushq.git statushq
COPY . /statushq

# Compiling elixir modules
WORKDIR /statushq
RUN mv docker/setup.sh setup.sh;\
    (cd apps/statushq/config; cp ce.prod.secret.exs prod.secret.exs);\
    rm -rf apps/statushq_pro;\
    mix do local.hex --force, local.rebar --force, deps.get, compile

# Building static assets
WORKDIR /statushq/apps/statushq
RUN mkdir -p priv/static;\
    yarn;\
    sed -i '/__pro__/d' ./lib/statushq_web/static/admin/css/app.scss;\
    sed -i '/__pro__/d' ./lib/statushq_web/static/app/css/app.scss;\
    npm run deploy;\
    npm run deploy:admin

# Building release
WORKDIR /statushq
RUN mix do phx.digest, release
