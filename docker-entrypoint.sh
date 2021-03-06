#!/bin/bash
set -euo pipefail

mkdir -p tmp
rm -rf tmp/pids

DO_RUN_BUNDLE_INSTALL=${RUN_BUNDLE_INSTALL:-0}
if [ $DO_RUN_BUNDLE_INSTALL -eq 1 ]; then
  echo "Running bundle install to update Gemfile.lock"
  bundle install --quiet
fi

# parse DATABASE_URL
proto="$(echo $DATABASE_URL | grep :// | sed -e's,^\(.*://\).*,\1,g')"
url="$(echo ${DATABASE_URL/$proto/})"
user="$(echo $url | grep @ | cut -d@ -f1)"
host_with_port="$(echo ${url/$user@/} | cut -d/ -f1)"
port="$(echo $host_with_port | sed -e 's,^.*:,:,g' -e 's,.*:\([0-9]*\).*,\1,g' -e 's,[^0-9],,g')"
host="$(echo ${host_with_port/:$port/})"

echo "Waiting for PG on tcp://$host:$port"
dockerize -wait tcp://$host:$port -timeout 1m

DO_RUN_DB_MIGRATE=${RUN_DB_MIGRATE:-1}
if [ $DO_RUN_DB_MIGRATE -ne 0 ]; then
  echo "Running DB migrations"
  bundle exec rails db:migrate
fi

echo "$@"
eval "$@"
