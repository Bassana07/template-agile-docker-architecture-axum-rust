# syntax=docker/dockerfile:1

FROM rust:1-bookworm AS builder

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends pkg-config libssl-dev \
	&& rm -rf /var/lib/apt/lists/*

COPY Cargo.toml Cargo.lock ./
COPY src ./src

RUN cargo build --release

FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates \
	&& rm -rf /var/lib/apt/lists/* \
	&& useradd -r -u 65532 -M -s /usr/sbin/nologin nonroot

WORKDIR /app

COPY --from=builder /app/target/release/mon-api-axum /usr/local/bin/mon-api-axum

USER nonroot:nonroot

EXPOSE 8200

ENV PORT=8200

ENTRYPOINT ["/usr/local/bin/mon-api-axum"]
