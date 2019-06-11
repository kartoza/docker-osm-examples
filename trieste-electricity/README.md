# Deploying instance in Rancher

* In order to run this environment we will deploy the docker-compose.yml in the specified
rancher environment.

* The docker-compose uses some tags which are not combatible in rancher so they will need to be changed in order 
for them to run in rancher.

## Using storage containers versus using a local mounted volume

* The current docker-compose uses local mounted volumes and since we need the files in `./docker-osm-settings`
for the orchestration to run. We have created a local storage image and pushed it to docker hub.

The following section will be replaced with a storage volume
```
imposm:
    image: kartoza/docker-osm:imposm-latest
    restart: always
    volumes:
      # These are sharable to other containers
      - ./docker-osm-settings/settings:/home/settings
      - import_done:/home/import_done
      - import_queue:/home/import_queue
      - cache:/home/cache
    depends_on:
        db:
          condition: service_healthy
```

* Rancher also does not support the following tags

``` 
depends_on:
        db:
          condition: service_healthy
```

In order to cater for all these scenarios we will use a modified docker-compose.yml file 
that is provided in this repo as `docker-compose-4-rancher.yml`

