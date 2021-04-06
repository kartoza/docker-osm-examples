# This image is intended to be used as a storage
# only container

FROM byrnedo/alpine-curl
MAINTAINER Tim Sutton <tim@kartoza.com>

RUN mkdir /settings
RUN wget http://download.geofabrik.de/asia/nepal-latest.osm.pbf -O settings/country.pbf
