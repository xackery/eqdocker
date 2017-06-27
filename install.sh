#THIS SHOULD ONLY BE RAN ONCE, unless there's a critical change or something. It builds up the images and preps the environment.
#This preps a docker environment for building binaries.

#!/bin/bash
set -e

echo "Shutting down docker-compose... (in case it was running)"
docker-compose down

if [ -f "env.txt" ]; then
	source env.txt
else 
	read -e -p "Enter git repo to pull source from (default: https://github.com/eqemu/server):" GITSOURCE
	if [ -z "${GITSOURCE}" ]; then
		GITSOURCE=https://github.com/eqemu/server
	fi
	
	read -e -p "Enter git repo to pull quests from (default: https://github.com/xackery/eqquests):" GITQUESTS
	if [ -z "${GITQUESTS}" ]; then
		GITQUESTS=https://github.com/xackery/eqquests
	fi

	read -e -p "Enter git repo to pull quests from (default: https://github.com/xackery/eqplugins):" GITPLUGINS
	if [ -z "${GITPLUGINS}" ]; then
		GITPLUGINS=https://github.com/xackery/eqplugins
	fi
	
	read -e -p "Enter git repo to pull maps from (default: https://github.com/xackery/eqmaps):" GITMAPS
	if [ -z "${GITMAPS}" ]; then
		GITMAPS=https://github.com/xackery/eqmaps
	fi

	read -e -p "Enter git repo to pull a base database from (default: https://github.com/xackery/eqdb):" GITDB
	if [ -z "${GITDB}" ]; then
		GITDB=https://github.com/xackery/eqdb
	fi

	read -p "Would you like to install EQEmu EOC in the web directory? (optional) [Y/n] (default: n): " REPLY
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		USEEOC=1
		read -e -p "Enter git repo to pull EQEmu EOC from (default: https://github.com/Akkadius/EQEmuEOC):" GITEOC
		if [ -z "${GITDB}" ]; then
			GITEOC=https://github.com/Akkadius/EQEmuEOC
		fi
	else
		read -p "Would you like to install PEQ PHP Editor in the web directory? (optional) [Y/n] (default: n): " REPLY
		if [[ $REPLY =~ ^[Yy]$ ]]; then
			USEPEQ=1
			read -e -p "Enter git repo to pull EQEmu EOC from (default: https://github.com/xackery/peqphpeditor):" GITPEQ
			if [ -z "${GITDB}" ]; then
				GITPEQ=https://github.com/xackery/peqphpeditor
			fi
		fi
	fi

	read -p "Instead of compiling source, we can use binaries. Want to? [Y/n] (default: n): " REPLY
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		USEPRECOMPILED=1
		read -e -p "Enter git repo to download binaries from (default: https://github.com/xackery/dockereq):" GITPEQ
		if [ -z "${GITPRECOMPILED}" ]; then
			GITPRECOMPILED=https://github.com/xackery/dockereq
		fi
	fi

	echo "Building env.txt, edit this file to change default options in future..."
	echo "export GITSOURCE=${GITSOURCE}" >> env.txt
	echo "export GITQUESTS=${GITQUESTS}" >> env.txt
	echo "export GITPLUGINS=${GITPLUGINS}" >> env.txt
	echo "export GITMAPS=${GITMAPS}" >> env.txt
	echo "export GITDB=${GITDB}" >> env.txt
	if [ ! -z "${GITEOC}" ]; then
		echo "export USEPRECOMPILED=${USEPRECOMPILED}" >> env.txt
		echo "export GITPRECOMPILED=${GITPRECOMPILED}" >> env.txt
	fi
	if [ ! -z "${GITEOC}" ]; then
		echo "export USEEOC=1" >> env.txt
		echo "export GITEOC=${GITEOC}" >> env.txt
	fi
	if [ ! -z "${GITPEQ}" ]; then
		echo "export USEPEQ=1" >> env.txt
		echo "export GITPEQ=${GITPEQ}" >> env.txt
	fi
	source env.txt
fi


if [ ! -d eqemu ]; then
   echo "Making eqemu directory..."
   mkdir eqemu
fi

cd eqemu
if [ -f ".gitignore" ]; then
	echo "Updating ${GITSOURCE} at eqemu/..."
	git pull
else
	echo "Cloning ${GITSOURCE} git to eqemu/..."
	git clone ${GITSOURCE} .
fi


if [ ! -d logs ]; then
   echo "Making logs directory..."
   mkdir logs
fi


if [ ! -d bin ]; then
   echo "Making eqemu/bin directory..."
   mkdir bin
fi
cd bin


if [ ! -f "opcodes.conf" ]; then
	echo "Copying *.conf to eqemu/bin/..."
	cp ../utils/patches/*.conf .
fi


if [ -d "maps" ]; then
	cd maps
	echo "Updating ${GITMAPS} to eqemu/bin/maps/..."
	git pull .
	cd ..
else
	echo "Cloning ${GITMAPS} git to eqemu/bin/maps/..."
	git clone ${GITMAPS} maps
fi


if [ -d "quests" ]; then
	cd quests
	echo "Updating ${GITQUESTS} to eqemu/bin/quests/..."
	git pull .
	cd ..
else
	echo "Cloning ${GITQUESTS} git to eqemu/bin/quests/..."
	git clone ${GITQUESTS} quests
fi


if [ -d "plugins" ]; then
	cd plugins
	echo "Updating ${GITPLUGINS} to eqemu/bin/plugins/..."
	git pull .
	cd ..
else
	echo "Cloning ${GITPLUGINS} git to eqemu/bin/plugins/..."
	git clone ${GITPLUGINS} plugins
fi

if [ -d "db" ]; then
	cd db
	echo "Updating ${GITDB} to eqemu/bin/db/..."
	git pull .
	cd ..
else
	echo "Cloning ${GITDB} git to eqemu/bin/db/..."
	git clone ${GITDB} db
fi

cd ../../

if [ ! -d db ]; then
   echo "Making root db directory..."
   mkdir db
fi

if [ ! -d html ]; then
   echo "Making root html directory..."
   mkdir html
fi

if [ ! -z "${USEPRECOMPILED}" ]; then
	cd eqemu/bin
	files=(
		'eqlaunch'
		'export_client_files'
		'import_client_files'
		'loginserver'
		'queryserv'
		'shared_memory'
		'ucs'
		'world'
		'zone'
		)

	for file in "${files[@]}"; do
		if [ ! -f ${file} ]; then
			echo "Downloading ${GITPRECOMPILED}/releases/download/latest/${file} to eqemu/bin/..."
			wget -nv -q ${GITPRECOMPILED}/releases/download/latest/${file} 2> /dev/null
			chmod +x ${file}
		fi
	done

	cd ../../
else
	echo "Building 'buildeq' docker container..."
	docker build docker/buildeq/. -t buildeq

	echo "Running cmake on buildeq..."
	docker run -v $PWD/eqemu:/src buildeq /bin/bash -c "/usr/bin/cmake ~/. -DEQEMU_BUILD_LOGIN=ON"

	echo "Building binaries in buildeq..."
	docker run -v $(pwd)/eqemu:/src buildeq
fi

echo "Building docker-compose environment..."
docker-compose build

if [ ! -d eqemu/bin/shared ]; then
   echo "Making shared directory..."
   mkdir -p eqemu/bin/shared
fi

files=(
	'eqemu_config.xml'
	'login.ini'
	'login_opcodes.conf'
	'login_opcodes_sod.conf'
	)
for file in "${files}"; do
	if [ ! -f eqemu/bin/${file} ]; then
	   echo "Copying to eqemu/bin/${file}..."
	   cp docker/eqemu/${file} eqemu/bin/
	fi
done


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


echo "Injecting DB..."
docker-compose up -d mariadb #detached mode

echo "Waiting 30s for mariadb to start... (since i'm too lazy to poll)"
sleep 30

ROOTDIR=$(pwd)
DBDIR=$(pwd)/eqemu/bin/db/
DOCKERDBDIR=/eqemu/db/

echo "Creating Tables..."
cd ${DBDIR}
for f in *.sql
do
	cd ${ROOTDIR}
	echo "$f..."
	docker-compose exec mariadb bash -c "/opt/bitnami/mariadb/bin/mysql -u eqemu -peqemu eqemu < ${DOCKERDBDIR}$f"
done

echo "Insert Data..."
cd ${DBDIR}
for f in *.txt
do
	cd ${ROOTDIR}
	echo "$f..."
	docker-compose exec mariadb bash -c "/opt/bitnami/mariadb/bin/mysqlimport --delete --host=127.0.0.1 --user=root --password=rootpass eqemu ${DOCKERDBDIR}$f"
done

if [ ! -z "${GITEOC}" ]; then
	cd html
	if [ -f ".gitignore" ]; then
		echo "Updating ${GITEOC} to html/..."
		git pull
	else
		echo "Cloning ${GITEOC} git to html/..."
		git clone ${GITEOC} .
	fi
	cp docker/web/eoc-config.php html/includes/config.php
fi

if [ ! -z "${GITPEQ}" ]; then
	cd html
	if [ -f ".gitignore" ]; then
		echo "Updating ${GITPEQ} to html/..."
		git pull
	else
		echo "Cloning ${GITPEQ} git to html/..."
		git clone ${GITPEQ} .
	fi
	cp docker/web/peq-config.php html/config.php
	echo "Injecting DB for PEQ PHP Editor..."
	docker-compose exec mariadb bash -c "/opt/bitnami/mariadb/bin/mysql -u eqemu -peqemu eqemu < /html/sql/schema.sql"
	#commented out since it errors: ERROR 1060 (42S21) at line 1: Duplicate column name 'expansion'
	#docker-compose exec mariadb bash -c "/opt/bitnami/mariadb/bin/mysql -u root eqemu < /html/sql/expansion.sql"
	docker-compose exec mariadb bash -c "/opt/bitnami/mariadb/bin/mysql -u eqemu -peqemu eqemu < /html/sql/aa_peq.sql"
fi

echo "Running shared memory..."
docker-compose run eqemu bash -c "/eqemu/shared_memory"

echo "Shutting down mariadb.."
docker-compose down

echo "Build completed. Run up.sh to start the environment."


