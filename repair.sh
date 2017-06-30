#!/bin/bash
set -e
docker-compose exec mariadb bash -c "/opt/bitnami/mariadb/bin/mysqlcheck -u root -prootpass --all-databases"