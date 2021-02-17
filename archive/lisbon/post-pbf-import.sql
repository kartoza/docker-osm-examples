alter table osm_roads add column road_type character varying (100);
alter table osm_roads add column length double precision;
alter table osm_roads add column length_class integer;

-- Run the following updates
update osm_roads set road_type = 'Motorway' WHERE  type ILIKE 'motorway' ;
update osm_roads set road_type = 'Highway' WHERE type ILIKE 'highway';
update osm_roads set road_type = 'Trunk' WHERE type ILIKE 'trunk' ;
update osm_roads set road_type = 'Motorway link' WHERE  type ILIKE 'motorway_link' ;
update osm_roads set road_type = 'Primary road' WHERE  type ILIKE 'primary';
update osm_roads set road_type = 'Primary link' WHERE  type ILIKE 'primary_link' ;
update osm_roads set road_type = 'Tertiary' WHERE  type ILIKE 'tertiary';
update osm_roads set road_type = 'Tertiary link' WHERE  type ILIKE 'tertiary_link';
update osm_roads set road_type = 'Secondary' WHERE  type ILIKE 'secondary';
update osm_roads set road_type = 'Secondary link' WHERE  type ILIKE 'secondary_link';
update osm_roads set road_type = 'Road, residential, living street, etc.' WHERE  type ILIKE 'living_street' OR type
ILIKE 'residential' OR type ILIKE 'yes' OR type ILIKE 'road' OR type ILIKE 'unclassified' OR type ILIKE 'service' OR type ILIKE '' OR type IS NULL
or type in ('steps','groyne','pier','trunk_link','bridleway','raceway','pedestrian','track','service','unclassified');
update osm_roads set road_type ='Bridge' WHERE  type LIKE 'bri%';
update osm_roads set road_type ='Track' WHERE  type ILIKE 'track';
update osm_roads set road_type =  'Cycleway, footpath, etc.' WHERE  type ILIKE 'cycleway' OR type ILIKE 'footpath'
        OR type ILIKE 'pedestrian' OR type ILIKE 'footway' OR type ILIKE 'path';

-- create indexes to use with the layer
CREATE INDEX idx_spgist_geom ON public.osm_roads USING spgist (geometry);
CREATE INDEX concurrently osm_id_idx on osm_roads(id);
CREATE INDEX concurrently osm_rd_type on osm_roads (road_type);
DROP index osm_roads_geom;

-- Update the road class to filter using road length
update osm_roads set length_class = 1 where road_type = 'Motorway' and length > 47261;


-- FUNCTION FOR IDENTIFY ADINISTRATOVE FOR LAT LANG --
-- WITH JUST lat, lng RETURN LIST OF ADMINISTRATIVE --
CREATE OR REPLACE FUNCTION identify_administrative(lat text, lng text)
  RETURNS TABLE (
	    osm_id bigint,
	    name VARCHAR,
	    level integer
	  ) AS
	$func$
	BEGIN
		  RETURN QUERY
		  SELECT osm.osm_id as osm_id, osm.name as name, osm.admin_level as level
		      FROM osm_admin as osm
		      CROSS JOIN (SELECT ST_MakePoint(CAST (lng AS float ),CAST (lat AS float ))::geography AS ref_geom) AS r
		      WHERE ST_INTERSECTS(geometry, ref_geom) ORDER BY osm.admin_level DESC;
	END
	$func$ LANGUAGE plpgsql;

	-- FUNCTION FOR GET STREET INTERSECTION --
-- WITH JUST street_id RETURNS LIST OF STREET --
CREATE OR REPLACE FUNCTION street_intersection(street_id text)
  RETURNS TABLE (
	    id integer ,
	    name VARCHAR,
	    osm_id bigint,
	    type VARCHAR,
	    class VARCHAR,
	    geometry geometry(LineString,4326)
	  ) AS
	$func$
	BEGIN
		  RETURN QUERY
		  SELECT b.id as id, b.name as name, b.osm_id as osm_id, b.type as type, b.class as class, b.geometry as geometry
		    FROM osm_roads as a
		    INNER JOIN osm_roads as b ON ST_Intersects(a.geometry, b.geometry) WHERE a.id = CAST (street_id AS integer ) and b.id != CAST (street_id AS integer );
	END
	$func$ LANGUAGE plpgsql;

