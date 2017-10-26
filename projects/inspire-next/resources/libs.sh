#!/bin/bash -x

KUBECTL=(
    /var/lib/jenkins/kubectl
    --kubeconfig=$K8S_CONFIG
    --namespace="commit-${COMMITHASH}-${BUILD_ID}"
)


libs.get_started_pods() {
    local started_jsonpath='{.items[*].status.containerStatuses[*].state.running.startedAt}'
    local timestamp_regex='\d{4}-\d{2}-\d{2}T\d{2}'

    "${KUBECTL[@]}" \
        get \
            --show-all \
            --output "jsonpath=$started_jsonpath" \
            pods | \
    grep \
        --perl-regex \
        --only-matching \
        --regexp="$timestamp_regex"
}


libs.get_num_started_pods() {
    libs.get_started_pods \
    | wc --lines
}


libs.is_number_of_started_pods() {
    [[ "$(libs.get_num_started_pods)" == $1 ]] \
    && return 0 \
    || return 1
}


libs.wait_for_number_of_pods() {
    while ! libs.is_number_of_started_pods $1; do
        sleep 2
    done
}


libs.pod_exit_code() {
    local terminated_jsonpath='{.status.containerStatuses[0].state.terminated.exitCode}'
    "${KUBECTL[@]}" \
        get \
            pod \
            $1 \
            --show-all \
            --output "jsonpath=$terminated_jsonpath" \
}


libs.wait_for_pod_to_exit() {
    while ! libs.pod_exit_code $1 | grep -q "^..*$"; do
        sleep 2
    done
}
