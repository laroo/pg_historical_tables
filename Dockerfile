FROM postgres:9.6-alpine

ENV LANG=C.UTF-8

RUN mkdir -p /pg
COPY . /pg
RUN chmod 755 /pg/test/run_tests.sh
RUN chown -R postgres:postgres /pg

USER postgres

WORKDIR /pg/test
ENTRYPOINT /pg/test/run_tests.sh
