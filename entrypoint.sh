#!/usr/bin/env bash

set -eu -o pipefail

BASE_DIR=${INPUT_BASE_DIR}
APP_TEMPLATE_DIR=${INPUT_APP_TEMPLATE_DIR}
APP_TARGET_DIR=${INPUT_APP_TARGET_DIR}
ARGO_TEMPLATE_FILE=${INPUT_ARGO_TEMPLATE_FILE}
ARGO_TARGET_FILE=${INPUT_ARGO_TARGET_FILE}
IMAGE=${INPUT_IMAGE}
NAMESPACE=${INPUT_NAMESPACE}
REPLACEMENTS=${INPUT_REPLACEMENTS}


echo "========Initialize=========="
(
if [ ! -d $(dirname ${BASE_DIR}/${APP_TARGET_DIR}) ]; then mkdir -p $(dirname ${BASE_DIR}/${APP_TARGET_DIR}); fi
if [ ! -d $(dirname ${BASE_DIR}/${ARGO_TARGET_FILE}) ]; then mkdir -p $(dirname ${BASE_DIR}/${ARGO_TARGET_FILE}); fi
)

echo "========Update application manifests=========="
(
if [ ! -d ${BASE_DIR}/${APP_TARGET_DIR} ]; then
  cp -r ${BASE_DIR}/${APP_TEMPLATE_DIR} ${BASE_DIR}/${APP_TARGET_DIR}
fi
cd ${BASE_DIR}/${APP_TARGET_DIR}
kustomize edit set image ${IMAGE}
kustomize edit set namespace ${NAMESPACE}
IFS=, ARR=(${REPLACEMENTS})
for r in "${ARR[@]}"; do
  before=$(echo $r | cut -d= -f1)
  after=$(echo $r | cut -d= -f2)
  sed -i -e s/$before/$after/g ./*
done
# output
cat kustomization.yaml
)

echo "========Generate ArgoCD app=========="
(
if [ ! -f ${BASE_DIR}/${ARGO_TARGET_FILE} ]; then
  cp ${BASE_DIR}/${ARGO_TEMPLATE_FILE} ${BASE_DIR}/${ARGO_TARGET_FILE}
fi
sed -i -e s/NAMESPACE/${NAMESPACE}/ ${BASE_DIR}/${ARGO_TARGET_FILE}
IFS=, ARR=(${REPLACEMENTS})
for r in "${ARR[@]}"; do
  before=$(echo $r | cut -d= -f1)
  after=$(echo $r | cut -d= -f2)
  sed -i -e s/$before/$after/g ${BASE_DIR}/${ARGO_TARGET_FILE}
done
)
