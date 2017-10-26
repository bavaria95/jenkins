#!/bin/bash -x

source jenkins/projects/inspire-next/resources/libs.sh

KUBECTL=(
    /var/lib/jenkins/kubectl
    --kubeconfig=$K8S_CONFIG
    --namespace="commit-${COMMITHASH}-${BUILD_ID}"
)


"${KUBECTL[@]}" \
    create \
        secret \
        docker-registry gitlabdocker \
        --docker-server=gitlab-registry.cern.ch \
        --docker-username="$GITLAB_USERNAME" \
        --docker-password="$GITLAB_PASSWORD" \
        --docker-email="${GITLAB_USERNAME}@cern.ch"


"${KUBECTL[@]}" \
    apply \
        --filename="jenkins/projects/inspire-next/resources/kub_config/deps" \
        --validate=false

libs.wait_for_number_of_pods 5


"${KUBECTL[@]}" \
    apply \
        --filename="jenkins/projects/inspire-next/resources/kub_config/web" \
        --validate=false

libs.wait_for_number_of_pods 7


"${KUBECTL[@]}" \
    apply \
        --filename="jenkins/projects/inspire-next/resources/kub_config/tests" \
        --validate=false

libs.wait_for_number_of_pods 8

libs.wait_for_pod_to_exit

PODNAME=$("${KUBECTL[@]}" "get pods -a | grep 'acceptance' | awk '{print \$1}'")
OUTPUT=$("${KUBECTL[@]}" logs "$PODNAME")
EXITCODE=$(libs.pod_exit_code)

echo $OUTPUT | grep -Po '(<\?xml.*</testsuite>)' > result.xml
exit $EXITCODE
