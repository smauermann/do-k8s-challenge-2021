#!/usr/bin/env bash

set -eu

if [ $(uname) = "Darwin" ] ; then
  sed -i '' \
    "s/namespace: .*/namespace: ${NAMESPACE}/" \
    ${STRIMZI_ARTIFACT}/install/cluster-operator/*RoleBinding*.yaml
else
  sed -i \
    "s/namespace: .*/namespace: ${NAMESPACE}/" \
    ${STRIMZI_ARTIFACT}/install/cluster-operator/*RoleBinding*.yaml
fi

kubectl apply -f ${STRIMZI_ARTIFACT}/install/cluster-operator -n ${NAMESPACE}
