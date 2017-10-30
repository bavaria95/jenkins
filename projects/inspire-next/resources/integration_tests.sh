#!/bin/bash -x

source jenkins/projects/inspire-next/resources/libs.sh

KUBECTL=(
    /var/lib/jenkins/kubectl
    --kubeconfig=$K8S_CONFIG
    --namespace="commit-${COMMITHASH}-${BUILD_ID}-integration"
)

services=( test-database test-indexer test-rabbitmq test-redis )
for service in "${services[@]}" do
    "${KUBECTL[@]}" \
        apply \
            --filename="jenkins/projects/inspire-next/resources/kub_config/deps/${service}-*" \
            --validate=false
done

libs.wait_for_number_of_pods 4

services=( test-worker )
for service in "${services[@]}" do
    "${KUBECTL[@]}" \
        apply \
            --filename="jenkins/projects/inspire-next/resources/kub_config/web/${service}-*" \
            --validate=false
done

libs.wait_for_number_of_pods 5


"${KUBECTL[@]}" \
    apply \
        --filename="jenkins/projects/inspire-next/resources/kub_config/tests/integration-job.yaml" \
        --validate=false

libs.wait_for_number_of_pods 6


PODNAME=$("${KUBECTL[@]}" get pods -a | grep 'Running' | grep 'integration' | awk '{print $1}')
libs.wait_for_pod_to_exit $PODNAME
OUTPUT=$("${KUBECTL[@]}" logs "$PODNAME")
echo $OUTPUT | grep -Po '(<\?xml.*</testsuite>)' > result_integration.xml
# number of tests failues
FAILURES=$(echo $OUTPUT | grep -Po '.*\K(?<=failures=")\d+(?=" )')
exit $FAILURES
