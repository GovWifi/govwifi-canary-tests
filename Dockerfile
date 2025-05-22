FROM ruby:3.3.6-alpine
ARG BUNDLE_INSTALL_CMD

ENV \
  LANG='C.UTF-8' \
  RACK_ENV=test

WORKDIR /usr/src/app

RUN apk add --no-cache --virtual .build-deps build-base && \
  apk add --no-cache openssl wpa_supplicant libc6-compat

COPY Gemfile Gemfile.lock .ruby-version ./
ARG BUNDLE_INSTALL_FLAGS
RUN bundle install --no-cache ${BUNDLE_INSTALL_FLAGS}

RUN apk del .build-deps

COPY . ./
