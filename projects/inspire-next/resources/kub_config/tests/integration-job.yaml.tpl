apiVersion: batch/v1
kind: Job
metadata:
  name: integration
spec:
  template:
    metadata:
      name: integration
    spec:
      containers:
      - command: ["/bin/bash"]
        args: ["-xmc", "source /virtualenv/bin/activate && py.test --junitxml=output.xml tests/integration --ignore tests/integration/workflows; EXITCODE=$?; cat output.xml; exit 0"]
        env:
          - name: APP_SQLALCHEMY_DATABASE_URI
            value: postgresql+psycopg2://inspirehep:dbpass123@test-database:5432/inspirehep
          - name: APP_BROKER_URL
            value: amqp://guest:guest@test-rabbitmq:5672//
          - name: APP_CELERY_RESULT_BACKEND
            value: amqp://guest:guest@test-rabbitmq:5672//
          - name: APP_CACHE_REDIS_URL
            value: redis://test-redis:6379/0
          - name: APP_ACCOUNTS_SESSION_REDIS_URL
            value: redis://test-redis:6379/2
          - name: APP_SEARCH_ELASTIC_HOSTS
            value: test-indexer
        image: @@IMAGE@@
        name: integration
      imagePullSecrets:
      - name: gitlabdocker
      restartPolicy: OnFailure
