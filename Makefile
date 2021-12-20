# include .env
SHELL := /bin/bash

help: ## shows this helpfile
	@grep --no-filename -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

setup: ## saves your password and ServerIP to .env 
	@echo 
	@echo New PiHole admin Password: && read -s password && echo 'WEBPASSWORD='$$password > ./.env && \
		echo "ServerIP=$$(hostname -I | awk '{print $$1}')" >> .env

start: ## mods system resolver and starts the PiHole container
	sudo sed -r -i.orig 's/#?DNSStubListener=yes/DNSStubListener=no/g' /etc/systemd/resolved.conf
	sudo sh -c 'rm /etc/resolv.conf && ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf'
	systemctl restart systemd-resolved
	docker-compose up -d

stop: ## stops the PiHole container and undos modifications of the system resolver
	docker-compose down
	sudo sed -r -i.orig 's/#?DNSStubListener=no/#DNSStubListener=yes/g' /etc/systemd/resolved.conf
	sudo sh -c 'rm /etc/resolv.conf && ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf'
	systemctl restart systemd-resolved

start2: ## completely stops system resolver and starts the pihole container
	sudo systemctl disable systemd-resolved.service
	sudo systemctl stop systemd-resolved
	docker-compose up -d

stop2: ## stops pihole and reenables the resolve service
	docker-compose down
	sudo systemctl enable systemd-resolved.service
	sudo systemctl start systemd-resolved

.PHONY: help setup start stop start2 stop2
.DEFAULT_GOAL := help
