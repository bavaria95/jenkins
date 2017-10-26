#!/bin/bash +e

source jenkins/projects/inspire-next/resources/libs.sh

KUBECTL=(
    /var/lib/jenkins/kubectl
    --kubeconfig=$K8S_CONFIG
    --namespace="commit-${COMMITHASH}-${BUILD_ID}"
)


"${KUBECTL[@]}" \
    delete \
        --filename=jenkins/projects/inspire-next/resources/kub_config/tests/

"${KUBECTL[@]}" \
    delete \
        --filename=jenkins/projects/inspire-next/resources/kub_config/web

"${KUBECTL[@]}" \
    delete \
        --filename=jenkins/projects/inspire-next/resources/kub_config/deps/

/var/lib/jenkins/kubectl \
    --kubeconfig=$K8S_CONFIG \
    delete namespace \
        "commit-${COMMITHASH}-${BUILD_ID}"

rm -rf {jenkins}
