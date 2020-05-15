# global args for multi-stage
ARG GOLANG_VER=1.14.2
ARG ALPINE_VER=3.11.6

FROM golang:$GOLANG_VER as builder
ARG target=caddy
ARG commit=44536a7
ARG OS=linux
ARG git_target=github.com/caddyserver/caddy/v2

ENV GO111MODULE=on \
    CGO_ENABLED=0 \
    GOOS=$OS \
    GOARCH=amd64 \
    GOPATH=/go/

RUN mkdir /go/${target}/
WORKDIR /go/${target}/
# TODO figure out way to add imports into main.go
COPY configs/main.go /go/${target}/main.go
RUN go mod init ${target}
RUN go get -u $git_target@${commit}
RUN go install
CMD tail -f /dev/null

#### Alpine Stage ####
FROM alpine:$ALPINE_VER
ARG target=caddy
ARG TARGET_PORT=2015
ENV TARGET_PORT=$TARGET_PORT \
    HOME=/root
EXPOSE $TARGET_PORT
COPY configs/ $HOME/
WORKDIR $HOME
COPY --from=builder /go/bin/${target} /usr/bin/${target}

CMD caddy run --watch