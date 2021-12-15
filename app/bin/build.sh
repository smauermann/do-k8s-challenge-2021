#!/usr/bin/env bash

set -e

REGISTRY=$1
SERVICE=$2

cd "app/$SERVICE"

docker build -t "$REGISTRY/kafka-$SERVICE" -f ../Dockerfile .