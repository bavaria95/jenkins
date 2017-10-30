#!/bin/bash -x

source jenkins/projects/inspire-next/resources/libs.sh

KUBECTL=(
    /var/lib/jenkins/kubectl
    --kubeconfig=$K8S_CONFIG
    --namespace="commit-${COMMITHASH}-${BUILD_ID}-acceptance"
)

services=( selenium test-database test-indexer test-rabbitmq test-redis )
for service in "${services[@]}" do
    "${KUBECTL[@]}" \
        apply \
            --filename="jenkins/projects/inspire-next/resources/kub_config/deps/${service}-*" \
            --validate=false
done

libs.wait_for_number_of_pods 5

services=( test-web test-worker )
for service in "${services[@]}" do
    "${KUBECTL[@]}" \
        apply \
            --filename="jenkins/projects/inspire-next/resources/kub_config/web/${service}-*" \
            --validate=false
done

libs.wait_for_number_of_pods 7


"${KUBECTL[@]}" \
    apply \
        --filename="jenkins/projects/inspire-next/resources/kub_config/tests/acceptance-job.yaml" \
        --validate=false

libs.wait_for_number_of_pods 8


PODNAME=$("${KUBECTL[@]}" get pods -a | grep 'Running' | grep 'acceptance' | awk '{print $1}')
libs.wait_for_pod_to_exit $PODNAME
OUTPUT=$("${KUBECTL[@]}" logs "$PODNAME")
echo $OUTPUT | grep -Po '(<\?xml.*</testsuite>)' > result_acceptance.xml
# number of tests failues
FAILURES=$(echo $OUTPUT | grep -Po '.*\K(?<=failures=")\d+(?=" )')
exit $FAILURES
