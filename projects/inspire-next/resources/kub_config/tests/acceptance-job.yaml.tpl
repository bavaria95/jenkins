apiVersion: batch/v1
kind: Job
metadata:
  name: acceptance
spec:
  template:
    metadata:
      name: acceptance
    spec:
      containers:
      - command: ["/bin/bash"]
        args: ["-xmc", "source /virtualenv/bin/activate && yum install Xvfb -y && { Xvfb :0 -ac -noreset & } && sleep 3 && stdbuf -o 0 py.test -s -vv --driver Firefox --host selenium --port '4444' --capability browserName firefox --html=selenium-report.html --junitxml=output.xml tests/acceptance; EXITCODE=$?; cat output.xml; exit $EXITCODE"]
        env:
          - name: APP_SERVER_NAME
            value: test-web:5000
          - name: SERVER_NAME
            value: test-web:5000
          - name: DISPLAY
            value: :0
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
        name: acceptance
        tty: true
        stdin: true
      restartPolicy: Never
