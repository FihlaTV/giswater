﻿/*
This file is part of Giswater
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: XXXX

CREATE OR REPLACE FUNCTION "SCHEMA_NAME".gw_trg_flw_regulator() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE 
flw_type_aux text;



BEGIN


    EXECUTE 'SET search_path TO '||quote_literal(TG_TABLE_SCHEMA)||', public';

    flw_type_aux= TG_ARGV[0];
	
	-- check to_arc only to that arcs that have node_1 as the flowregulator node
	IF to_arc IS NULL THEN
		RAISE EXCEPTION 'You need to set a value of to_arc column before continue';
	ELSE 
		IF ((SELECT arc_id FROM v_edit_arc WHERE arc_id=NEW.to_arc AND node_1=NEW.node_id) IS NULL) THEN
			RAISE EXCEPTION 'You need to set to_arc/node_id values with topologic coherency. Node_id must be the node_1 of the exic arc feature';
		END IF;

	END IF;
		
	-- check flow_length as much as total length of exit arc
	IF (SELECT st_length(v_edit_arc.them_geom) FROM v_edit_arc WHERE arc_id=NEW.to_arc)<(flow_length) THEN
	ELSE
		RAISE EXCEPTION 'Flow length is longer than length of exit arc feature. Please review your project!';
	END IF;
	
	-- flowreg_id
	IF NEW.flwreg_id IS NULL THEN
		NEW.flwreg_id = EXECUTE 'SELECT COUNT(*) FROM inp_flwreg_'||flw_type_aux||' WHERE to_arc=NEW.to_arc AND node_id=NEW.node_id)';
	END IF;


RETURN NEW;
    
END; 
$$;


DROP TRIGGER IF EXISTS gw_trg_flw_regulator ON "SCHEMA_NAME"."inp_flwreg_orifice";
CREATE TRIGGER gw_trg_flw_regulator BEFORE INSERT OR UPDATE ON "SCHEMA_NAME"."inp_flwreg_orifice" 
FOR EACH ROW EXECUTE PROCEDURE "SCHEMA_NAME"."gw_trg_flw_regulator"('orifice');


DROP TRIGGER IF EXISTS gw_trg_flw_regulator ON "SCHEMA_NAME"."inp_flwreg_outlet";
CREATE TRIGGER gw_trg_flw_regulator BEFORE INSERT OR UPDATE ON "SCHEMA_NAME"."inp_flwreg_outlet" 
FOR EACH ROW EXECUTE PROCEDURE "SCHEMA_NAME"."gw_trg_flw_regulator"('outlet');


DROP TRIGGER IF EXISTS gw_trg_flw_regulator ON "SCHEMA_NAME"."inp_flwreg_weir";
CREATE TRIGGER gw_trg_flw_regulator BEFORE INSERT OR UPDATE ON "SCHEMA_NAME"."inp_flwreg_weir" 
FOR EACH ROW EXECUTE PROCEDURE "SCHEMA_NAME"."gw_trg_flw_regulator"('weir');


DROP TRIGGER IF EXISTS gw_trg_flw_regulator ON "SCHEMA_NAME"."inp_flwreg_pump";
CREATE TRIGGER gw_trg_flw_regulator BEFORE INSERT OR UPDATE ON "SCHEMA_NAME"."inp_flwreg_pump" 
FOR EACH ROW EXECUTE PROCEDURE "SCHEMA_NAME"."gw_trg_flw_regulator"('pump');