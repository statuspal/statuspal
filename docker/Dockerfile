####   Build Image

FROM elixir:alpine

ENV MIX_ENV prod

RUN apk add --no-cache nodejs nodejs-npm yarn bash git openssh alpine-sdk python2

RUN mkdir /build
WORKDIR /build

# mix deps
COPY ./mix.* ./
COPY ./apps/statushq/mix.* ./apps/statushq/
RUN echo "Compiling app..."\
  && mix do local.hex --force, local.rebar --force, deps.get, compile

# Install npm modules
COPY ./package.json ./package.json
COPY ./yarn.lock ./yarn.lock
COPY ./.babelrc ./.babelrc
COPY ./apps/statushq/webpack*.js ./apps/statushq/
COPY ./apps/statushq/lib/statushq_web/static ./apps/statushq/lib/statushq_web/static

# Building static assets
RUN mkdir -p apps/statushq/priv/static\
  && yarn\
  && npm run prod:build

COPY . ./
RUN rm -rf ./apps/statushq_pro

RUN mix do phx.digest, release --no-tar --env=prod

####   Runtime Image

FROM alpine:latest

LABEL maintainer="Eduardo Messuti <messuti.edd@gmail.com>"\
  description="Statushq CE"

ENV REPLACE_OS_VARS true
ENV MIX_ENV prod

RUN apk --no-cache add postgresql-client bash openssl-dev imagemagick
WORKDIR /statushq
COPY --from=0 /build/rel ./rel
COPY --from=0 /build/docker ./docker

CMD ["/statushq/docker/up.sh"]
