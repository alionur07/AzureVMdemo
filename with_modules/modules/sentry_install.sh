#!/usr/bin/env bash
docker run -d --name sentry-redis redis
docker run -d --name sentry-postgres -e POSTGRES_PASSWORD=secret -e POSTGRES_USER=sentry postgres
docker run -d --rm -e SENTRY_SECRET_KEY='d(%g+zbi(5002iaxt=ktoh_o_wv&4zpgc4_b@t@-7y6ar5=w6q' --link sentry-postgres:postgres --link sentry-redis:redis sentry upgrade --noinput
docker run -d --name sentry-user -e SENTRY_SECRET_KEY='d(%g+zbi(5002iaxt=ktoh_o_wv&4zpgc4_b@t@-7y6ar5=w6q' --link sentry-postgres:postgres --link sentry-redis:redis sentry createuser --email sayilgan.yavuz@gmail.com --password admin --superuser --no-input
docker run -p 80:9000 -d --name my-sentry -e SENTRY_SECRET_KEY='$d(%g+zbi(5002iaxt=ktoh_o_wv&4zpgc4_b@t@-7y6ar5=w6q' --link sentry-redis:redis --link sentry-postgres:postgres sentry
docker run -d --name sentry-cron -e SENTRY_SECRET_KEY='d(%g+zbi(5002iaxt=ktoh_o_wv&4zpgc4_b@t@-7y6ar5=w6q' --link sentry-postgres:postgres --link sentry-redis:redis sentry run cron
docker run -d --name sentry-worker-1 -e SENTRY_SECRET_KEY='d(%g+zbi(5002iaxt=ktoh_o_wv&4zpgc4_b@t@-7y6ar5=w6q' --link sentry-postgres:postgres --link sentry-redis:redis sentry run worker
