VERSION ?= latest
#VERSION ?= $(shell git rev-parse --abbrev-ref HEAD)

ifeq ($(OS),Windows_NT)
	HOST_IP ?= 10.0.75.1
else
	UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S),Darwin)
		HOST_IP ?= host.docker.internal
	else
		HOST_IP ?= $(shell ip -4 addr show docker0 | grep -Po 'inet \K[\d.]+')
	endif
endif

docker_compose=VERSION=$(VERSION) HOST_IP=$(HOST_IP) docker compose 

requirements:
	$(docker_compose) pull

build:
	$(docker_compose) build --no-cache

serve:
	$(docker_compose) up
serve/hard:
	$(docker_compose) up --force-recreate --build

exec/app: args=-w /var/www/html
exec/db:
exec/%:
	$(docker_compose) exec $(args) $* bash

sandbox/app:
sandbox/db:
sandbox/%:
	$(docker_compose) run --rm -i --entrypoint bash $*

clean:
	$(docker_compose) down -v --rmi all