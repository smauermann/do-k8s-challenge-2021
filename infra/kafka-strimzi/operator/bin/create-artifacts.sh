#!/usr/bin/env bash

set -eu

curl -sSL -o ${STRIMZI_ARTIFACT}.zip \
  https://github.com/strimzi/strimzi-kafka-operator/releases/download/${STRIMZI_VERSION}/${STRIMZI_ARTIFACT}.zip

unzip -oq ${STRIMZI_ARTIFACT}.zip && rm -rf ${STRIMZI_ARTIFACT}.zip
