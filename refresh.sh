#!/bin/bash

# Refreshes the environment, pulling down latest git repos and such.
set -e
if [ -f "env.txt" ]; then
   source env.txt
else 
   echo "env.txt not found. This usually means you need to run install.sh, or something is severely wrong."
   exit
fi

echo "Stopping EQEMU Containers.."
docker-compose down


if [ ! -d eqemu ]; then
   echo "error: eqemu/ not found"
   exit 1
fi

cd eqemu
if [ -f ".gitignore" ]; then
   echo "Updating ${GITSOURCE} at eqemu/..."
else
   echo "error: eqemu/.gitignore not found"
   exit 1
fi

cd bin

if [ ! -d maps ]; then
   echo "error: eqemu/maps/ not found"
   exit 1
fi

cd maps
if [ -f ".gitignore" ]; then
   echo "Updating ${GITMAPS} to eqemu/bin/maps/..."
   #git pull
else
   echo "error: eqemu/maps/ not found"
   exit 1
fi

cd ..
if [ ! -d quests ]; then
   echo "error: eqemu/quests/ not found"
   exit 1
fi


cd quests
if [ -f ".gitignore" ]; then
   echo "Updating ${GITQUESTS} to eqemu/bin/quests/..."
   #git pull
else
   echo "error: eqemu/quests/ not found"
fi

cd ..
if [ ! -d plugins ]; then
   echo "error: eqemu/bin/plugins/ not found"
   exit 1
fi


cd plugins
if [ -f ".gitignore" ]; then
   echo "Updating ${GITPLUGINS} to eqemu/bin/plugins/..."
   #git pull
else
   echo "error: eqemu/plugins/ not found"
fi

cd ../../../
echo "Building binaries in buildeq..."
docker run -v $(pwd)/eqemu:/src buildeq

echo "Running shared memory..."
docker-compose run eqemu /eqemu/shared_memory