#!/bin/bash

REPO=gitlab-registry.cern.ch/inspire/jenkins/inspire-base


sed -e "s|@@IMAGE@@|inspire-base:${COMMITHASH}-${BUILD_ID}|g" \
    jenkins/projects/inspire-next/resources/kub_config/builder.yaml.tpl > \
    jenkins/projects/inspire-next/resources/kub_config/builder.yaml
rm jenkins/projects/inspire-next/resources/kub_config/builder.yaml.tpl

sed -i -e "s|@@GITLAB_USERNAME@@|${GITLAB_USERNAME}|g" \
    jenkins/projects/inspire-next/resources/kub_config/builder.yaml
sed -i -e "s|@@GITLAB_PASSWORD@@|${GITLAB_PASSWORD}|g" \
    jenkins/projects/inspire-next/resources/kub_config/builder.yaml


sed -e "s|@@IMAGE@@|${REPO}:${COMMITHASH}-${BUILD_ID}|g" \
    jenkins/projects/inspire-next/resources/kub_config/web/test-web-deployment.yaml.tpl > \
    jenkins/projects/inspire-next/resources/kub_config/web/test-web-deployment.yaml
rm jenkins/projects/inspire-next/resources/kub_config/web/test-web-deployment.yaml.tpl

sed -e "s|@@IMAGE@@|${REPO}:${COMMITHASH}-${BUILD_ID}|g" \
    jenkins/projects/inspire-next/resources/kub_config/web/test-worker-deployment.yaml.tpl > \
    jenkins/projects/inspire-next/resources/kub_config/web/test-worker-deployment.yaml
rm jenkins/projects/inspire-next/resources/kub_config/web/test-worker-deployment.yaml.tpl

sed -e "s|@@IMAGE@@|${REPO}:${COMMITHASH}-${BUILD_ID}|g" \
    jenkins/projects/inspire-next/resources/kub_config/tests/unit-job.yaml.tpl > \
    jenkins/projects/inspire-next/resources/kub_config/tests/unit-job.yaml
rm jenkins/projects/inspire-next/resources/kub_config/tests/unit-job.yaml.tpl


sed -i -e "s|ca.pem|${K8S_CA}|g" "$K8S_CONFIG"
sed -i -e "s|cert.pem|${K8S_CERT}|g" "$K8S_CONFIG"
sed -i -e "s|key.pem|${K8S_KEY}|g" "$K8S_CONFIG"


/var/lib/jenkins/kubectl \
    --kubeconfig="$K8S_CONFIG" \
    create namespace \
        "commit-${COMMITHASH}-${BUILD_ID}"
