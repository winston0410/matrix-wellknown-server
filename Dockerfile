FROM golang:1.22.4-bullseye as server_build

COPY go.mod go.sum /appbuild/

COPY ./ /appbuild

RUN set -ex \
    && go version \
    && cd /appbuild \
    && CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -mod=vendor -o server

# Build deployable server
FROM scratch
WORKDIR /opt/server
COPY --from=server_build /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=server_build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=server_build /etc/passwd /etc/passwd
COPY --from=server_build /etc/group /etc/group
COPY --from=server_build /appbuild/server /opt/server

EXPOSE 8080

CMD ["./server"]
