#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace

echo "Running tests:"

initdb /var/lib/postgresql/data
pg_ctl -D /var/lib/postgresql/data start

RETRIES=5
until psql -c "select 1" > /dev/null 2>&1 || [ $RETRIES -eq 0 ]; do
  echo "Waiting for postgres server, $((RETRIES)) remaining attempts..."
  RETRIES=$((RETRIES-=1))
  sleep 1
done

mkdir -p result

TEMPORAL_TRIGGER_FUNCTIONS="temporal_trigger_function temporal_trigger_function_optimized"
TESTS="basic existing_table"

for temporal_trigger_function in $TEMPORAL_TRIGGER_FUNCTIONS; do
  for name in $TESTS; do
    echo ""
    echo "${temporal_trigger_function}: ${name}"
    echo ""
    createdb temporal_tables_test
    psql temporal_tables_test -q -f "../${temporal_trigger_function}.sql"

    psql temporal_tables_test -X -a -q --set=SHOW_CONTEXT=never < sql/$name.sql > result/$name.out 2>&1
    diff -b expected/$name.out result/$name.out
    dropdb temporal_tables_test

  done
done
