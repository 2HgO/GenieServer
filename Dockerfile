FROM julia:1.4-buster

RUN mkdir -p /app

WORKDIR /app

COPY . .

RUN julia deps/build.jl

ENV JULIA_LOAD_PATH="/app/src:${JULIA_LOAD_PATH}"