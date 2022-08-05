#!/usr/bin/env bash

set -ex

for i in `seq 1..50`; do
    docker-compose exec tst psql -X -q -h pg1,pg2 -U ad -b analytics -c "select 1 as ping from pg_stat_statements LIMIT 1"
done
