#!/bin/bash
set -e

echo "WARNING!!! THIS IS A NON-REVERSABLE DELETE REQUEST OF ALL DATA"

read -p "Are you sure you want to continue? This deletes *all* downloaded files, database, making a clean start! (Y/n) [n]: " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
	echo "Aborting"
	exit 1
fi


echo "Shutting down docker-compose..."
docker-compose down

if [ -d eqemu ]; then
	echo "Removing eqemu/..."
	rm -rf eqemu
fi

if [ -d db ]; then
	echo "Removing db/..."
	rm -rf db
fi

if [ -d html ]; then
	echo "Removing html/..."
	rm -rf html
fi

if [ -f env.txt ]; then 
	echo "Removing env.txt..."
	rm env.txt
fi

echo "Done. Optionally say yes below to prune stopped containers"
docker container prune