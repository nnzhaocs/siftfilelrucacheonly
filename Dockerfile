FROM golang:latest

ENV DISTRIBUTION_DIR /go/src/github.com/docker/distribution
ENV DOCKER_BUILDTAGS include_oss include_gcs

ARG GOOS=linux
ARG GOARCH=amd64

#RUN set -ex \
#    && apk add --no-cache make git

WORKDIR $DISTRIBUTION_DIR
COPY . $DISTRIBUTION_DIR

RUN mkdir -p /go/src/bitbucket.com/milit93/ && mkdir -p ~/.ssh/ && mkdir -p /go/src/github.com/docker/docker

RUN ssh-keyscan -t rsa github.com > ~/.ssh/known_hosts

#RUN  cd /go/src/bitbucket.com/milit93/ 
RUN git clone https://github.com/nnzhaocs/consistenthash_sha256 /go/src/bitbucket.com/milit93/consistenthash_sha256/
RUN git clone https://github.com/moby/moby.git /go/src/github.com/docker/docker
#https://github.com/nnzhaocs/consistenthash_sha256

RUN apt-get update && apt-get install -y libzookeeper-mt-dev
RUN go get github.com/ngaut/log && go get github.com/allegro/bigcache && go get launchpad.net/gozk/zookeeper

#RUN cd $DISTRIBUTION_DIR

COPY cmd/registry/config-dev.yml /etc/docker/registry/config.yml

RUN make PREFIX=/go clean binaries

VOLUME ["/var/lib/registry"]
EXPOSE 5000
ENTRYPOINT ["registry"]
CMD ["serve", "/etc/docker/registry/config.yml"]
