FROM postgres:10-alpine

ENV LANG=C.UTF-8

RUN apk add --no-cache pgxnclient
RUN pgxn install temporal_tables

RUN mkdir -p /pg
COPY . /pg
RUN chmod 755 /pg/test/run_tests.sh /pg/test/run_performance_test.sh
RUN chown -R postgres:postgres /pg

USER postgres

WORKDIR /pg/test
CMD /bin/echo "Welcome to 'pg_historical_tables'; use [COMMAND] to execute action"
