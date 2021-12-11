#!/usr/bin/env bash

set -eu

kubectl delete -f ${STRIMZI_ARTIFACT}/install/cluster-operator -n ${NAMESPACE}
