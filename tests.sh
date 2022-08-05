#!/usr/bin/env bash

set -e


fctLoop() {
    for i in `seq 1 50`; do
        docker-compose exec -T app psql -X -q -h pg1,pg2 -U ad -b analytics -c "select 1 as ping from pg_stat_statements LIMIT 1"
        docker-compose exec -T app psql -X -q -h pg1,pg2 -U ad -b analytics -c "select 2 as ping from pg_stat_statements LIMIT 1"
        docker-compose exec -T app psql -X -q -h pg1,pg2 -U ad -b analytics -c "select 3 as ping from pg_stat_statements LIMIT 1"
        docker-compose exec -T app psql -X -q -h pg1,pg2 -U ad -b analytics -c "select 4 as ping from pg_stat_statements LIMIT 1"
        docker-compose exec -T mon pg_autoctl show state
        sleep 1
    done
}

echo "#############################################################"
echo "# Starting env"
docker-compose up -d
sleep 5
docker-compose exec -T mon psql -b pg_auto_failover -c "ALTER SYSTEM SET pgautofailover.health_check_period TO 4000;"
docker-compose exec -T mon psql -b pg_auto_failover -c "ALTER SYSTEM SET pgautofailover.health_check_retry_delay  TO 400;"
docker-compose exec -T mon psql -b pg_auto_failover -c "ALTER SYSTEM SET  pgautofailover.health_check_timeout  TO 1000;"
sleep 2

echo "#############################################################"
echo "# Running tests"

mkdir -p results

fctLoop > results/loop.log &

docker-compose stop pg1
docker-compose rm -f pg1
sleep 20

docker-compose up -d

sleep 10

wait

# docker-compose down

if diff -r expected results; then
    echo "tests ok"
else
    echo "tests FAILED !!!"
fi
