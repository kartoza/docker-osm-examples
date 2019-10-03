CREATE VIEW osm_buildings_view as
select id,
       osm_id,
       CASE
           WHEN amenity ILIKE '%school%' OR amenity ILIKE '%kindergarten%' THEN 'School'
           WHEN amenity ILIKE '%university%' OR amenity ILIKE '%college%' THEN 'University/College'
           WHEN amenity ILIKE '%government%' THEN 'Government'
           WHEN amenity ILIKE '%clinic%' OR amenity ILIKE '%doctor%' THEN 'Clinic/Doctor'
           WHEN amenity ILIKE '%hospital%' THEN 'Hospital'
           WHEN amenity ILIKE '%fire%' THEN 'Fire Station'
           WHEN amenity ILIKE '%police%' THEN 'Police Station'


           WHEN amenity ILIKE '%public building%' THEN 'Public Building'
           WHEN amenity ILIKE '%worship%' and (religion ILIKE '%islam' or religion ILIKE '%muslim%')
               THEN 'Place of Worship -Islam'

           WHEN amenity ILIKE '%worship%' and religion ILIKE '%budd%' THEN 'Place of Worship -Buddhist'
           WHEN amenity ILIKE '%worship%' and religion ILIKE '%unitarian%' THEN 'Place of Worship -Unitarian'
           WHEN amenity ILIKE '%mall%' OR amenity ILIKE '%market%' THEN 'Supermarket'

           WHEN landuse ILIKE '%residential%' OR use = 'residential' THEN 'Residential'
           WHEN landuse ILIKE '%recreation_ground%' OR (leisure IS NOT NULL AND leisure != '') THEN 'Sports Facility'

           -- run near the end
           WHEN use = 'government' AND "type" IS NULL THEN 'Government'

           WHEN use = 'residential' AND "type" IS NULL THEN 'Residential'
           WHEN use = 'education' AND "type" IS NULL THEN 'School'
           WHEN use = 'medical' AND "type" IS NULL THEN 'Clinic/Doctor'
           WHEN use = 'place_of_worship' AND "type" IS NULL THEN 'Place of Worship'
           WHEN use = 'school' AND "type" IS NULL THEN 'School'
           WHEN use = 'hospital' AND "type" IS NULL THEN 'Hospital'
           WHEN use = 'commercial' AND "type" IS NULL THEN 'Commercial'

           WHEN use = 'industrial' AND "type" IS NULL THEN 'Industrial'
           WHEN use = 'utility' AND "type" IS NULL THEN 'Utility'
           -- Add default type
           WHEN "type" IS NULL THEN 'Residential'
        END as building_type,
           geometry
FROM osm_buildings;

-- Add a trigger function to notify QGIS of DB changes
CREATE FUNCTION public.notify_qgis() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        BEGIN NOTIFY qgis;
        RETURN NULL;
        END;
    $$;

-- Based on the tables defined in the mapping.yml create triggers

CREATE TRIGGER notify_admin
  AFTER INSERT OR UPDATE OR DELETE  ON public.osm_admin
    FOR EACH STATEMENT EXECUTE PROCEDURE public.notify_qgis();

    CREATE TRIGGER notify_buildings
  AFTER INSERT OR UPDATE OR DELETE  ON public.osm_buildings
    FOR EACH STATEMENT EXECUTE PROCEDURE public.notify_qgis();


    CREATE TRIGGER notify_roads
  AFTER INSERT OR UPDATE OR DELETE  ON public.osm_roads
    FOR EACH STATEMENT EXECUTE PROCEDURE public.notify_qgis();

    CREATE TRIGGER notify_waterways
  AFTER INSERT OR UPDATE OR DELETE  ON public.osm_waterways
    FOR EACH STATEMENT EXECUTE PROCEDURE public.notify_qgis();


ALTER table osm_buildings add column building_type numeric;

CREATE OR REPLACE FUNCTION building_type_mapper () RETURNS trigger LANGUAGE plpgsql
AS $$
BEGIN
    update osm_buildings set build_type =

    CASE
        WHEN "building:use" = 'accomodation' THEN 0.5
        WHEN "building:use" = 'commercial' THEN 0.5
        WHEN "building:use" = 'education' THEN 1
        WHEN "building:use" = 'government' THEN 0.5
        WHEN "building:use" = 'multipurpose' THEN 0.3
        WHEN "building:use" = 'place_of_worship' THEN 0.5
        WHEN "building:use" = 'residential' THEN 1
        WHEN "building:use" = 'ruko' THEN 1
        WHEN "building:use" = 'shop' THEN 0.5
        WHEN "building:use" = 'storage' THEN 0.5
        ELSE 0.3
        END
    ;
  RETURN NEW;
  END
  $$;

CREATE TRIGGER type_mapper BEFORE INSERT OR UPDATE ON osm_buildings FOR EACH ROW EXECUTE PROCEDURE building_type_mapper();


