apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  creationTimestamp: null
  name: test-web
spec:
  replicas: 1
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        service: test-web
    spec:
      containers:
      - args:
        - gunicorn
        - -b
        - 0.0.0.0:5000
        - -t
        - "3600"
        - -w
        - "1"
        - --access-logfile
        - '-'
        - inspirehep.wsgi_with_coverage:application
        env:
        - name: APP_SERVER_NAME
          value: test-web:5000
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
        name: test-web
        tty: true
        stdin: true
        resources: {}
      imagePullSecrets:
      - name: gitlabdocker
      restartPolicy: Always
status: {}
