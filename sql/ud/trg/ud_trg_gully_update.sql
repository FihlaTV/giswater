﻿/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_trg_gully_update() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE 
    querystring Varchar; 
    linkrec Record; 
    gullyRecord1 Record;
    gullyRecord2 Record;

BEGIN 

    EXECUTE 'SET search_path TO '||quote_literal(TG_TABLE_SCHEMA)||', public';

--  Select links with start-end on the updated node
	querystring := 'SELECT * FROM link WHERE (link.feature_id = ' || quote_literal(NEW.connec_id) || ' 
	AND feature_type=''GULLY'') OR (link.exit_id = ' || quote_literal(NEW.gully_id)|| ' AND feature_type=''GULLY'');'; 
	FOR linkrec IN EXECUTE querystring
	LOOP
		-- Initial and final gully of the LINK
		SELECT * INTO gullyRecord1 FROM v_edit_gully WHERE v_edit_gully.gully_id = linkrec.feature_id;
		SELECT * INTO gullyRecord2 FROM v_edit_gully WHERE v_edit_gully.gully_id = linkrec.exit_id;

		-- Update link
		IF (gullyRecord1.gully_id = NEW.gully_id) THEN
			EXECUTE 'UPDATE link SET the_geom = ST_SetPoint($1, 0, $2) WHERE link_id = ' || quote_literal(linkrec."link_id") USING linkrec.the_geom, NEW.the_geom; 
		ELSIF (gullyRecord2.gully_id = NEW.gully_id) THEN
			EXECUTE 'UPDATE link SET the_geom = ST_SetPoint($1, ST_NumPoints($1) - 1, $2) WHERE link_id = ' || quote_literal(linkrec."link_id") USING linkrec.the_geom, NEW.the_geom; 
		END IF;
	END LOOP;


    RETURN NEW;
    
END; 
$$;


DROP TRIGGER IF EXISTS gw_trg_gully_update ON "SCHEMA_NAME"."gully";
CREATE TRIGGER gw_trg_gully_update AFTER UPDATE OF the_geom ON "SCHEMA_NAME"."gully" 
FOR EACH ROW EXECUTE PROCEDURE "SCHEMA_NAME"."gw_trg_gully_update"();