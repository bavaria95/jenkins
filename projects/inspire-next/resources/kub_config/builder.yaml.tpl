apiVersion: batch/v1
kind: Job
metadata:
  name: docker-builder
spec:
  template:
    metadata:
      name: docker-builder
    spec:
      containers:
      - command: ["/bin/bash"]
        args: ["-xmc", "curl -fsSL https://get.docker.com/builds/Linux/x86_64/docker-latest.tgz | tar xvz && 
                    apt-get update && 
                    apt-get install -y git && 
                    git clone https://github.com/inspirehep/inspire-next.git && 
                    git clone -b acceptance-tests https://$GITLAB_USERNAME:$GITLAB_PASSWORD@gitlab.cern.ch/inspire/jenkins.git && 
                    mv jenkins/projects/inspire-next/resources/Dockerfile inspire-next/ && 
                    cd inspire-next && 
                    COMMITHASH=$(git rev-parse HEAD) && 
                    echo $COMMITHASH && 
                    ../docker/docker build -t gitlab-registry.cern.ch/inspire/jenkins/@@IMAGE@@ . && 
                    ../docker/docker login gitlab-registry.cern.ch -u @@GITLAB_USERNAME@@ -p @@GITLAB_PASSWORD@@ && 
                    ../docker/docker push gitlab-registry.cern.ch/inspire/jenkins/@@IMAGE@@ &&
                    exit 0"
                ]
        image: tutum/curl
        name: docker-builder
        tty: true
        stdin: true
        volumeMounts:
        - mountPath: /var/run/docker.sock
          name: docker-socket
      volumes:
      - name: docker-socket
        hostPath:
          path: /var/run/docker.sock
      restartPolicy: OnFailure
