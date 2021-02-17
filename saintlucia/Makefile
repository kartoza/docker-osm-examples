PROJECT_ID := saintlucia-osm-mirror
COMPOSE := -f docker-compose.yml

SHELL := /bin/bash

# ----------------------------------------------------------------------------
#    P R O D U C T I O N     C O M M A N D S
# ----------------------------------------------------------------------------
deploy: run-docker-pbf-fetcher run
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Bringing up docker osm instance and loading clip region"
	@echo "------------------------------------------------------------------"

run: run-docker-pbf-fetcher 
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Bringing up docker osm instance "
	@echo "------------------------------------------------------------------"
	@docker-compose -f docker-compose.yml -p $(PROJECT_ID) up -d --no-recreate 

run-docker-pbf-fetcher:
	@echo "------------------------------------------------------------------"
	@echo "Get country pbf and copying to settings folder"
	@echo "------------------------------------------------------------------"
	$(MAKE) -C docker-pbf-fetcher get-pbf

kill:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Killing in production mode"
	@echo "------------------------------------------------------------------"
	@docker-compose $(COMPOSE) -p $(PROJECT_ID) kill

rm: kill
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Removing production instance!!! "
	@echo "------------------------------------------------------------------"
	@docker-compose $(COMPOSE) -p $(PROJECT_ID) rm

rm-volumes:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Removing all volumes!!!! "
	@echo "------------------------------------------------------------------"
	@docker volume rm $(PROJECT_ID)_osm-postgis-data $(PROJECT_ID)_import_queue $(PROJECT_ID)_import_done $(PROJECT_ID)_cache

logs:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Show logs of stack status"
	@echo "------------------------------------------------------------------"
	@docker-compose -f docker-compose.yml -p $(PROJECT_ID) logs --tail 100 -f
