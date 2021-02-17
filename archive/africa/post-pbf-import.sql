ALTER TABLE osm_roads add column road_type character varying (100);
ALTER TABLE osm_roads add column length double precision;
ALTER TABLE osm_buildings add column building_type character varying (100);
ALTER TABLE osm_buildings add column building_area numeric;



-- Run the following UPDATEs
UPDATE osm_roads SET road_type = 'Motorway' WHERE  type ILIKE 'motorway' ;
UPDATE osm_roads SET road_type = 'Highway' WHERE type ILIKE 'highway';
UPDATE osm_roads SET road_type = 'Trunk' WHERE type ILIKE 'trunk' ;
UPDATE osm_roads SET road_type = 'Motorway link' WHERE  type ILIKE 'motorway_link' ;
UPDATE osm_roads SET road_type = 'Primary road' WHERE  type ILIKE 'primary';
UPDATE osm_roads SET road_type = 'Primary link' WHERE  type ILIKE 'primary_link' ;
UPDATE osm_roads SET road_type = 'Tertiary' WHERE  type ILIKE 'tertiary';
UPDATE osm_roads SET road_type = 'Tertiary link' WHERE  type ILIKE 'tertiary_link';
UPDATE osm_roads SET road_type = 'Secondary' WHERE  type ILIKE 'secondary';
UPDATE osm_roads SET road_type = 'Secondary link' WHERE  type ILIKE 'secondary_link';
UPDATE osm_roads SET road_type = 'Road, residential, living street, etc.' WHERE  type ILIKE 'living_street' OR type
ILIKE 'residential' OR type ILIKE 'yes' OR type ILIKE 'road' OR type ILIKE 'unclassified' OR type ILIKE 'service' OR type ILIKE '' OR type IS NULL
or type in ('steps','groyne','pier','trunk_link','bridleway','raceway','pedestrian','track','service','unclassified');
UPDATE osm_roads SET road_type ='Bridge' WHERE  type LIKE 'bri%';
UPDATE osm_roads SET road_type ='Track' WHERE  type ILIKE 'track';
UPDATE osm_roads SET road_type =  'Cycleway, footpath, etc.' WHERE  type ILIKE 'cycleway' OR type ILIKE 'footpath'
        OR type ILIKE 'pedestrian' OR type ILIKE 'footway' OR type ILIKE 'path';

-- create indexes to use with the layer
CREATE INDEX idx_spgist_geom ON public.osm_roads USING spgist (geometry);
CREATE INDEX concurrently osm_id_idx on osm_roads(id);
CREATE INDEX concurrently osm_rd_type on osm_roads (road_type);
DROP INDEX osm_roads_geom;




UPDATE osm_buildings SET building_type = 'School' WHERE amenity ILIKE '%school%' OR amenity ILIKE '%kindergarten%' ;
UPDATE osm_buildings SET building_type = 'University/College'   WHERE amenity ILIKE '%university%' OR amenity ILIKE '%college%' ;
UPDATE osm_buildings SET building_type = 'Government'  WHERE amenity ILIKE '%government%' ;
UPDATE osm_buildings SET building_type = 'Clinic/Doctor'  WHERE amenity ILIKE '%clinic%' OR amenity ILIKE '%doctor%' ;
UPDATE osm_buildings SET building_type = 'Hospital' WHERE amenity ILIKE '%hospital%' ;
UPDATE osm_buildings SET building_type = 'Fire Station'  WHERE amenity ILIKE '%fire%' ;
UPDATE osm_buildings SET building_type = 'Police Station' WHERE amenity ILIKE '%police%' ;
UPDATE osm_buildings SET building_type = 'Public Building' WHERE amenity ILIKE '%public building%' ;

UPDATE osm_buildings SET building_type = 'Place of Worship -Islam' WHERE amenity ILIKE '%worship%'
                                                        and (religion ILIKE '%islam' or religion ILIKE '%muslim%');
UPDATE osm_buildings SET building_type = 'Residential'  WHERE amenity = 'yes' ;
UPDATE osm_buildings SET building_type = 'Place of Worship -Buddhist' WHERE amenity ILIKE '%worship%' and religion ILIKE '%budd%';
UPDATE osm_buildings SET building_type = 'Place of Worship -Unitarian'  WHERE amenity ILIKE '%worship%' and religion ILIKE '%unitarian%' ;
UPDATE osm_buildings SET building_type = 'Supermarket'  WHERE amenity ILIKE '%mall%' OR amenity ILIKE '%market%' ;
UPDATE osm_buildings SET building_type = 'Residential'  WHERE landuse ILIKE '%residential%' OR use = 'residential';
UPDATE osm_buildings SET building_type = 'Sports Facility' WHERE landuse ILIKE '%recreation_ground%'
                                                              OR (leisure IS NOT NULL AND leisure != '') ;
           -- run near the end
UPDATE osm_buildings SET building_type = 'Government'  WHERE use = 'government' AND "type" IS NULL ;
UPDATE osm_buildings SET building_type = 'Residential'  WHERE use = 'residential' AND "type" IS NULL ;
UPDATE osm_buildings SET building_type = 'School'  WHERE use = 'education' AND "type" IS NULL ;
UPDATE osm_buildings SET building_type = 'Clinic/Doctor' WHERE use = 'medical' AND "type" IS NULL ;
UPDATE osm_buildings SET building_type = 'Place of Worship'  WHERE use = 'place_of_worship' AND "type" IS NULL ;
UPDATE osm_buildings SET building_type = 'School'   WHERE use = 'school' AND "type" IS NULL ;
UPDATE osm_buildings SET building_type = 'Hospital'   WHERE use = 'hospital' AND "type" IS NULL ;
UPDATE osm_buildings SET building_type = 'Commercial'   WHERE use = 'commercial' AND "type" IS NULL ;
UPDATE osm_buildings SET building_type = 'Industrial'   WHERE use = 'industrial' AND "type" IS NULL ;
UPDATE osm_buildings SET building_type = 'Utility'   WHERE use = 'utility' AND "type" IS NULL ;
           -- Add default type
UPDATE osm_buildings SET building_type = 'Residential'  WHERE "type" IS NULL ;
UPDATE osm_buildings SET building_area  = ST_Area(geometry::GEOGRAPHY) ;



-- Create a QGIS notification signal
CREATE FUNCTION public.notify_qgis() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ 
        BEGIN NOTIFY qgis;
        RETURN NULL;
        END; 
    $$;

CREATE TRIGGER notify_qgis_osm_admin 
  AFTER INSERT OR UPDATE OR DELETE  ON public.osm_admin
    FOR EACH STATEMENT EXECUTE PROCEDURE public.notify_qgis();

CREATE TRIGGER notify_qgis_osm_buildings 
  AFTER INSERT OR UPDATE OR DELETE  ON public.osm_buildings
    FOR EACH STATEMENT EXECUTE PROCEDURE public.notify_qgis();

CREATE TRIGGER notify_qgis_osm_lakes 
  AFTER INSERT OR UPDATE OR DELETE  ON public.osm_lakes
    FOR EACH STATEMENT EXECUTE PROCEDURE public.notify_qgis();


CREATE TRIGGER notify_qgis_osm_landuse 
  AFTER INSERT OR UPDATE OR DELETE  ON public.osm_landuse
    FOR EACH STATEMENT EXECUTE PROCEDURE public.notify_qgis();

CREATE TRIGGER notify_qgis_osm_national_parks 
  AFTER INSERT OR UPDATE OR DELETE  ON public.osm_national_parks
    FOR EACH STATEMENT EXECUTE PROCEDURE public.notify_qgis();

CREATE TRIGGER notify_qgis_osm_parks
  AFTER INSERT OR UPDATE OR DELETE  ON public.osm_parks
    FOR EACH STATEMENT EXECUTE PROCEDURE public.notify_qgis();


 CREATE TRIGGER notify_qgis_osm_places 
  AFTER INSERT OR UPDATE OR DELETE  ON public.osm_places
    FOR EACH STATEMENT EXECUTE PROCEDURE public.notify_qgis();

 CREATE TRIGGER notify_qgis_osm_roads 
  AFTER INSERT OR UPDATE OR DELETE  ON public.osm_roads
    FOR EACH STATEMENT EXECUTE PROCEDURE public.notify_qgis();

 CREATE TRIGGER notify_qgis_osm_waterways 
  AFTER INSERT OR UPDATE OR DELETE  ON public.osm_waterways
    FOR EACH STATEMENT EXECUTE PROCEDURE public.notify_qgis();