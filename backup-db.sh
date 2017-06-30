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

echo "Removing past backup..."
rm -rf backup/db/*

echo "Backing up database to backup/db/..."
docker-compose exec mariadb /opt/bitnami/mariadb/bin/mysqldump -u root -prootpass --tab=/backup/db/ eqemu

echo "Removing date garbage..."
for file in backup/db/*.sql; do
		cat ${file} | sed '/-- Dump/d' > backup/tmp.sql
		mv backup/tmp.sql ${file}
done