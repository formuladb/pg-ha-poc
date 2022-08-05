#!/usr/bin/env bash

set -ex

sleep 5

docker-compose exec mon pg_autoctl show state