
FROM alpine:3.24.3

RUN apk add --no-cache \
    gcc-arm-none-eabi \
    g++-arm-none-eabi \
    cmake \
    ninja \
    git

