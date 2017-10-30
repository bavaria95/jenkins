#!/bin/bash -x

source jenkins/projects/inspire-next/resources/libs.sh

KUBECTL=(
    /var/lib/jenkins/kubectl
    --kubeconfig=$K8S_CONFIG
    --namespace="commit-${COMMITHASH}-${BUILD_ID}-builder"
)


"${KUBECTL[@]}" \
    apply \
        --filename="jenkins/projects/inspire-next/resources/kub_config/builder.yaml" \
        --validate=false \


libs.wait_for_number_of_pods 1

PODNAME=$("${KUBECTL[@]}" get pods -a | grep 'builder' | awk '{print $1}')

libs.wait_for_pod_to_exit $PODNAME

OUTPUT=$("${KUBECTL[@]}" logs "$PODNAME")
echo $OUTPUT

EXITCODE=$(libs.pod_exit_code $PODNAME)

"${KUBECTL[@]}" \
    delete \
        --filename="jenkins/projects/inspire-next/resources/kub_config/builder.yaml"

exit $EXITCODE
