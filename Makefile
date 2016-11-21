AUTHOR=tleijtens
NAME=bigchaindb
BCDBDATA=bigchaindbdata
PWD=/dockerbackup
NETWORKID=42
SUBNET=10.0.42
VERSION=bigchaindb

start:	bigchaindb

stop:
	docker stop -t 0 $(NAME)

clean:
	docker rm -f $(NAME)

cleanrestart:	clean start

network:
	docker network create --subnet $(SUBNET).0/24 --gateway $(SUBNET).254 icec

datavolume:
	docker run -d -v $(BCDBDATA):/data --name $(BCDBDATA) --entrypoint /bin/echo debian:wheezy

backup:
	docker run --rm --volumes-from $(BCDBDATA) -v $(PWD):/backup debian:wheezy bash -c "tar zcvf /backup/$(BCDBDATA).tgz data"

restore:
	docker run --rm --volumes-from $(BCDBDATA) -v $(PWD):/backup debian:wheezy bash -c "tar zxvf /backup/$(BCDBDATA).tgz"

rmnetwork:
	docker network rm icec

help:
	docker run -i $(NAME)/$(NAME):$(VERSION) help

init:
	docker run --rm --volumes-from=$(BCDBDATA) -ti $(NAME)/$(NAME) -y  configure

bigchaindb:
	docker run -d --net icec --ip $(SUBNET).13 -e SUBNET=$(SUBNET) -p 59984:9984 -p 58080:8080 --volumes-from=$(BCDBDATA) --name $(NAME) $(NAME)/$(NAME) start

rmbigchaindb:
	docker rm -f $(NAME)

rmdatavolumes:
	docker rm -f $(BCDBDATA)
	docker volume rm $(BCDBDATA)
