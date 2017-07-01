clean: 
	./delete.sh
.PHONY: clean

build:
	./refresh.sh
.PHONY: build

down:
	./down.sh
.PHONY: down

install:
	./install.sh
.PHONY: install

repair:
	./repair.sh
.PHONY: repair
	
up:
	./up.sh
.PHONY: up

backup-db:
	./backup-db.sh
.PHONY: backup-db

restore-db:
	./restore-db.sh
.PHONY: restore-db