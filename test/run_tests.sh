#!/usr/bin/env bash

set -eux

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

TESTS="basic existing_table"

for name in $TESTS; do
	echo ""
	echo $name
	echo ""
	createdb temporal_tables_test
	psql temporal_tables_test -q -f ../temporal_trigger_function.sql

	psql temporal_tables_test -X -a -q --set=SHOW_CONTEXT=never < sql/$name.sql > result/$name.out 2>&1
	diff -b expected/$name.out result/$name.out
	dropdb temporal_tables_test
	
done
