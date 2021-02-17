PROJECT_ID := saintlucia-osm-mirror
get-pbf:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Fetching pbf if not cached and then copying to settings dir"
	@echo "------------------------------------------------------------------"
	@docker build -t "$(PROJECT_ID)-rofile:latest" .
	@docker run -d --name $(PROJECT_ID)_pbf $(PROJECT_ID)-profile
	@docker cp $(PROJECT_ID)_pbf:/settings/country.pbf ../settings
	@docker rm -f $(PROJECT_ID)_pbf
	@cd ..
