#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace

TEMPORAL_FUNCTION=$1

echo "Running Performance test: ${TEMPORAL_FUNCTION}"

initdb /var/lib/postgresql/data
pg_ctl -D /var/lib/postgresql/data start

RETRIES=5
until psql -c "select 1" > /dev/null 2>&1 || [ $RETRIES -eq 0 ]; do
  echo "Waiting for postgres server, $((RETRIES)) remaining attempts..."
  RETRIES=$((RETRIES-=1))
  sleep 1
done

createdb temporal_tables_test
#psql temporal_tables_test -q -f "../${TEMPORAL_TRIGGER_FUNCTION}"

echo "DB Setup"
psql temporal_tables_test -q -f "./performance/${TEMPORAL_FUNCTION}/setup.sql"

echo "Insert"
psql temporal_tables_test -q -f ./performance/insert.sql
echo "Update"
psql temporal_tables_test -q -f ./performance/update.sql
echo "Delete"
psql temporal_tables_test -q -f ./performance/delete.sql

echo "DB teardown"
dropdb temporal_tables_test
