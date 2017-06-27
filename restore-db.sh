#!/bin/bash
set -e

echo "continue?"

ROOTDIR=$(pwd)
DBDIR=$(pwd)/eqemu/bin/db/
#DBDIR=$(pwd)/backup/db/
#DOCKERDBDIR=/backup/db/
DOCKERDBDIR=/eqemu/db/

echo "Creating Tables..."
cd ${DBDIR}
for f in *.sql
do
	cd ${ROOTDIR}
	echo "$f..."
	docker-compose exec mariadb bash -c "/opt/bitnami/mariadb/bin/mysql -u root eqemu < ${DOCKERDBDIR}$f"
done

echo "Insert data..."
cd ${DBDIR}
for f in *.txt
do
	cd ${ROOTDIR}
	echo "$f..."
	docker-compose exec mariadb bash -c "/opt/bitnami/mariadb/bin/mysqlimport -u root eqemu ${DOCKERDBDIR}$f"
done