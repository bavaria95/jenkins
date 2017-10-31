#!/bin/bash +e

source jenkins/projects/inspire-next/resources/libs.sh

KUBECTL=(
    /var/lib/jenkins/kubectl
    --kubeconfig=$K8S_CONFIG
)


envs=( builder acceptance integration unit workflows )

for e in "${envs[@]}"; do
    "${KUBECTL[@]}" \
    --namespace="commit-${COMMITHASH}-${BUILD_ID}-${e}" \
        delete \
            --filename=jenkins/projects/inspire-next/resources/kub_config/tests

    "${KUBECTL[@]}" \
    --namespace="commit-${COMMITHASH}-${BUILD_ID}-${e}" \
        delete \
            --filename=jenkins/projects/inspire-next/resources/kub_config/web

    "${KUBECTL[@]}" \
    --namespace="commit-${COMMITHASH}-${BUILD_ID}-${e}" \
        delete \
            --filename=jenkins/projects/inspire-next/resources/kub_config/deps


    "${KUBECTL[@]}" \
        delete namespace \
            "commit-${COMMITHASH}-${BUILD_ID}-${e}"
done


rm -rf {jenkins}

exit 0
