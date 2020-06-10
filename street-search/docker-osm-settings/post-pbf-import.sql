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

-- FUNCTION FOR IDENTIFY NEAREST STREET --
-- WITH JUST lat, lng RETURN LIST OF NEAREST STREET --
CREATE OR REPLACE FUNCTION identify_nearest_street(lat text, lng text)
  RETURNS TABLE (
    id integer,
    name VARCHAR
  ) AS
$func$
BEGIN
  RETURN QUERY
  SELECT osm.id as id, osm.name as name
      FROM osm_roads as osm
      WHERE ST_DWithin(geometry, ST_MakePoint(CAST (lng AS float ),CAST (lat AS float ))::geography, 100)
      ORDER BY ST_Distance(geometry, ST_MakePoint(CAST (lng AS float ),CAST (lat AS float ))::geography);
END
$func$ LANGUAGE plpgsql;