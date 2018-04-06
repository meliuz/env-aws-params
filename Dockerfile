FROM golang:1.9.5

ENV APPLICATION_NAME env-aws-params

RUN apt-get update && apt-get install -y unzip --no-install-recommends && \
    apt-get autoremove -y && apt-get clean -y && \
    wget -O dep https://github.com/golang/dep/releases/download/v0.4.1/dep-linux-amd64 && \
    echo '31144e465e52ffbc0035248a10ddea61a09bf28b00784fd3fdd9882c8cbb2315  dep' | sha256sum -c - && \
    chmod +x dep && mv dep /usr/local/bin

RUN mkdir -p /go/src/github.com/${APPLICATION_NAME}
WORKDIR /go/src/github.com/${APPLICATION_NAME}

COPY Gopkg.toml Gopkg.lock ./

RUN dep ensure -vendor-only
