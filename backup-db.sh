#!/bin/bash
set -e
if [ ! -d backup ]; then
   echo "Making root backup directory..."
   mkdir backup
fi
cd backup
if [ ! -d db ]; then
   echo "Making backup/db directory..."
   mkdir db
fi
cd ../

#echo "Ensuring mariadb is up..."
#docker-compose up mariadb

echo "Removing past backup..."
rm -rf backup/db/*

echo "Backing up database to backup/..."
docker-compose exec mariadb /opt/bitnami/mariadb/bin/mysqldump -u root -prootpass --tab=/backup/db/ eqemu