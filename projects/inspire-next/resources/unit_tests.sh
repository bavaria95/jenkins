#!/bin/bash -x

source jenkins/projects/inspire-next/resources/libs.sh

KUBECTL=(
    /var/lib/jenkins/kubectl
    --kubeconfig=$K8S_CONFIG
    --namespace="commit-${COMMITHASH}-${BUILD_ID}-unit"
)


"${KUBECTL[@]}" \
    apply \
        --filename="jenkins/projects/inspire-next/resources/kub_config/tests/unit-job.yaml" \
        --validate=false

libs.wait_for_number_of_pods 1


PODNAME=$("${KUBECTL[@]}" get pods -a | grep 'Running' | grep 'unit' | awk '{print $1}')
libs.wait_for_pod_to_exit $PODNAME
OUTPUT=$("${KUBECTL[@]}" logs "$PODNAME")
echo $OUTPUT | grep -Po '(<\?xml.*</testsuite>)' > result_unit.xml
# number of tests failues
FAILURES=$(echo $OUTPUT | grep -Po '.*\K(?<=failures=")\d+(?=" )')
# number of tests errors
ERRORS=$(echo $OUTPUT | grep -Po '.*\K(?<=errors=")\d+(?=" )')
TOTAL=$(($FAILURES+$ERRORS))
exit $TOTAL