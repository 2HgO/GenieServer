FROM julia:1.4-buster

RUN mkdir -p /app

WORKDIR /app

COPY . .

RUN julia deps/build.jl

ENV JULIA_LOAD_PATH="/app/src/configs/env:/app/src/handlers:/app/src/models:/app/src/configs/db:/app/src/utils:/app/src/errors:/app/src/controllers:/app/src/routes:${JULIA_LOAD_PATH}"