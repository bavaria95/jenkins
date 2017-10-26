apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  creationTimestamp: null
  name: test-worker
spec:
  replicas: 1
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        service: test-worker
    spec:
      containers:
      - args:
        - celery
        - worker
        - -E
        - -A
        - inspirehep.celery
        - --loglevel=INFO
        - --purge
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
        name: test-worker
        tty: true
        stdin: true
        resources: {}
      imagePullSecrets:
      - name: gitlabdocker
      restartPolicy: Always
status: {}
