FROM golang:1.9.5 AS builder

ARG APPLICATION_NAME

RUN apt-get update && apt-get install -y unzip --no-install-recommends && \
    apt-get autoremove -y && apt-get clean -y && \
    rm -rf /var/lib/apt/lists/* && \
    wget -O dep https://github.com/golang/dep/releases/download/v0.4.1/dep-linux-amd64 && \
    echo '31144e465e52ffbc0035248a10ddea61a09bf28b00784fd3fdd9882c8cbb2315  dep' | sha256sum -c - && \
    chmod +x dep && mv dep /usr/local/bin

WORKDIR /go/src/github.com/${APPLICATION_NAME}

COPY Gopkg.toml Gopkg.lock ./
RUN dep ensure -vendor-only

COPY . .
RUN go build && go test

FROM scratch

ARG APPLICATION_NAME

WORKDIR /app
COPY --from=builder /go/src/github.com/${APPLICATION_NAME} .
