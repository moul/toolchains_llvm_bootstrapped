FROM ubuntu AS build
RUN apt update && apt install -y ca-certificates git && apt clean

# XXX: failed attempt to make a more minimal version
#FROM alpine:3.18 AS build
#RUN apk add --no-cache libc6-compat bash git build-base linux-headers zlib-dev openjdk17
#ENV JAVA_HOME=/usr/lib/jvm/default-jvm
#ENV PATH=$JAVA_HOME/bin:$PATH

ADD https://github.com/bazelbuild/bazelisk/releases/download/v1.26.0/bazelisk-linux-amd64 /usr/bin/bazelisk
RUN chmod +x /usr/bin/bazelisk
#RUN bazelisk
ADD . /opt/src

FROM build AS test
WORKDIR /opt/src/examples/rules_cc
RUN bazelisk build :main
RUN ./bazel-bin/main

FROM build
WORKDIR /opt/src
