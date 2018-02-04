﻿/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE:XXXX


DROP FUNCTION IF EXISTS "SCHEMA_NAME".gw_fct_epa_audit_check_data(character varying );
CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_fct_epa_audit_check_data ( character varying)  RETURNS integer AS $BODY$
DECLARE

rec_options 		record;
valve_rec			record;
count_global_aux	integer;
rec_var				record;
setvalue_int		int8;
project_type_aux 	text;
count_aux			integer;
infiltration_aux	text;
rgage_rec			record;



BEGIN

	--  Search path	
	SET search_path = "SCHEMA_NAME", public;
	
	
	-- select config values
	SELECT * INTO rec_options FROM inp_options;
	SELECT wsoftware INTO project_type_aux FROM version LIMIT 1;

	-- init variables
	count_aux=0;
	count_global_aux=0;	

	-- delete old values on result table
	DELETE FROM audit_check_data WHERE fprocesscat_id=14 AND result_id=result_id_var;

	
	-- Starting process
	
	-- UTILS
	-- Check disconnected nodes (14)
	FOR rec_var IN SELECT node_id FROM rpt_inp_node WHERE result_id=result_id_var AND node_id NOT IN (SELECT node_1 FROM rpt_inp_arc WHERE result_id=result_id_var UNION SELECT node_2 FROM rpt_inp_arc WHERE result_id=result_id_var)
	LOOP
		INSERT INTO audit_check_data (fprocesscat_id, result_id, table_id, column_id, error_message) 
		VALUES (14, result_id_var, rec_var, 'node', 'Node is disconnected');
		count_global_aux=count_global_aux+count_aux;
		
	END LOOP;
		
	
	-- only UD projects
	IF 	project_type_aux='UD' THEN
	
		--Set value default
		UPDATE inp_outfall SET outfall_type=(SELECT value FROM config_param_user WHERE parameter='epa_outfall_type_vdefault') WHERE outfall_type IS NULL;
		UPDATE inp_conduit SET q0=(SELECT value FROM config_param_user WHERE parameter='epa_conduit_q0_vdefault') WHERE q0 IS NULL;
		UPDATE inp_conduit SET barrels=(SELECT value FROM config_param_user WHERE parameter='epa_conduit_barrels_vdefault') WHERE barrels IS NULL;
		UPDATE inp_junction SET y0=(SELECT value FROM config_param_user WHERE parameter='epa_junction_y0_vdefault') WHERE y0 IS NULL;
		UPDATE raingage SET scf=(SELECT value FROM config_param_user WHERE parameter='epa_rgage_scf_vdefault') WHERE scf IS NULL;
				

		-- check common mistakes
		SELECT count(*) INTO count_aux FROM v_edit_subcatchment where node_id is null;
		IF count_aux > 0 THEN
			INSERT INTO audit_check_data (fprocesscat_id, result_id, table_id, column_id, error_message) 
			VALUES (14, result_id_var,'Subcatchments','node_id', concat('There are ',count_aux,' with null values on node_id column'));
			count_global_aux=count_global_aux+count_aux; 
			count_aux=0;
		END IF;

		SELECT count(*) INTO count_aux FROM v_edit_subcatchment where rg_id is null;
		IF count_aux > 0 THEN
			INSERT INTO audit_check_data (fprocesscat_id, result_id, table_id, column_id, error_message) 
			VALUES (14, result_id_var,'Subcatchments','rg_id', concat('There are ',count_aux,' with null values on rg_id column'));
			count_global_aux=count_global_aux+count_aux; 
			count_aux=0;
		END IF;

		SELECT count(*) INTO count_aux FROM v_edit_subcatchment where area is null;
		IF count_aux > 0 THEN
			INSERT INTO audit_check_data (fprocesscat_id, result_id, table_id, column_id, error_message) 
			VALUES (14, result_id_var,'Subcatchments','area', concat('There are ',count_aux,' with null values on area column'));
			count_global_aux=count_global_aux+count_aux; 
			count_aux=0;
		END IF;

		SELECT count(*) INTO count_aux FROM v_edit_subcatchment where width is null;
		IF count_aux > 0 THEN
			INSERT INTO audit_check_data (fprocesscat_id, result_id, table_id, column_id, error_message) 
			VALUES (14, result_id_var,'Subcatchments','width', concat('There are ',count_aux,' with null values on width column'));
			count_global_aux=count_global_aux+count_aux; 
			count_aux=0;
		END IF;
		
		SELECT count(*) INTO count_aux FROM v_edit_subcatchment where slope is null;
		IF count_aux > 0 THEN
			INSERT INTO audit_check_data (fprocesscat_id, result_id, table_id, column_id, error_message) 
			VALUES (14, result_id_var,'Subcatchments','slope', concat('There are ',count_aux,' with null values on slope column'));
			count_global_aux=count_global_aux+count_aux; 
			count_aux=0;
		END IF;

		SELECT count(*) INTO count_aux FROM v_edit_subcatchment where clength is null;
		IF count_aux > 0 THEN
			INSERT INTO audit_check_data (fprocesscat_id, result_id, table_id, column_id, error_message) 
			VALUES (14, result_id_var,'Subcatchments','clength', concat('There are ',count_aux,' with null values on clength column'));
			count_global_aux=count_global_aux+count_aux; 
			count_aux=0;
		END IF;

		SELECT count(*) INTO count_aux FROM v_edit_subcatchment where nimp is null;
		IF count_aux > 0 THEN
			INSERT INTO audit_check_data (fprocesscat_id, result_id, table_id, column_id, error_message) 
			VALUES (14, result_id_var,'Subcatchments','nimp', concat('There are ',count_aux,' with null values on nimp column'));
			count_global_aux=count_global_aux+count_aux; 
			count_aux=0;
		END IF;
		
		SELECT count(*) INTO count_aux FROM v_edit_subcatchment where nperv is null;
		IF count_aux > 0 THEN
			INSERT INTO audit_check_data (fprocesscat_id, result_id, table_id, column_id, error_message) 
			VALUES (14, result_id_var,'Subcatchments','nperv', concat('There are ',count_aux,' with null values on nperv column'));
			count_global_aux=count_global_aux+count_aux; 
			count_aux=0;
		END IF;

		SELECT count(*) INTO count_aux FROM v_edit_subcatchment where simp is null;
		IF count_aux > 0 THEN
			INSERT INTO audit_check_data (fprocesscat_id, result_id, table_id, column_id, error_message) 
			VALUES (14, result_id_var,'Subcatchments','simp', concat('There are ',count_aux,' with null values on simp column'));
			count_global_aux=count_global_aux+count_aux; 
			count_aux=0;
		END IF;

		SELECT count(*) INTO count_aux FROM v_edit_subcatchment where sperv is null;
		IF count_aux > 0 THEN
			INSERT INTO audit_check_data (fprocesscat_id, result_id, table_id, column_id, error_message) 
			VALUES (14, result_id_var,'Subcatchments','sperv', concat('There are ',count_aux,' with null values on sperv column'));
			count_global_aux=count_global_aux+count_aux; 
			count_aux=0;
		END IF;
		
		SELECT count(*) INTO count_aux FROM v_edit_subcatchment where zero is null;
		IF count_aux > 0 THEN
			INSERT INTO audit_check_data (fprocesscat_id, result_id, table_id, column_id, error_message) 
			VALUES (14, result_id_var,'Subcatchments','zero', concat('There are ',count_aux,' with null values on zero column'));
			count_global_aux=count_global_aux+count_aux; 
			count_aux=0;
		END IF;

		SELECT count(*) INTO count_aux FROM v_edit_subcatchment where routeto is null;
		IF count_aux > 0 THEN
			INSERT INTO audit_check_data (fprocesscat_id, result_id, table_id, column_id, error_message) 
			VALUES (14, result_id_var,'Subcatchments','routeto', concat('There are ',count_aux,' with null values on routeto column'));
			count_global_aux=count_global_aux+count_aux; 
			count_aux=0;
		END IF;

		
		SELECT count(*) INTO count_aux FROM v_edit_subcatchment where rted is null;
		IF count_aux > 0 THEN
			INSERT INTO audit_check_data (fprocesscat_id, result_id, table_id, column_id, error_message) 
			VALUES (14, result_id_var,'Subcatchments','rted', concat('There are ',count_aux,' with null values on rted column'));
			count_global_aux=count_global_aux+count_aux; 
			count_aux=0;
		END IF;

		SELECT infiltration INTO infiltration_aux FROM cat_hydrology JOIN inp_selector_hydrology
		ON inp_selector_hydrology.hydrology_id=cat_hydrology.hydrology_id WHERE cur_user=current_user;
		
		IF infiltration_aux='CURVE NUMBER' THEN
		
			SELECT count(*) INTO count_aux FROM v_edit_subcatchment where (curveno is null) 
			OR (conduct_2 is null) OR (drytime_2 is null);
			
			IF count_aux > 0 THEN
				INSERT INTO audit_check_data (fprocesscat_id, result_id, table_id, column_id, error_message) 
				VALUES (14, result_id_var,'Subcatchments','Various', concat('There are ',count_aux,' with null values on curve number infiltartion method columns (curveno, conduct_2, drytime_2)'));
				count_global_aux=count_global_aux+count_aux; 
				count_aux=0;
			END IF;
		
		ELSIF infiltration_aux='GREEN_AMPT' THEN
		
			SELECT count(*) INTO count_aux FROM v_edit_subcatchment where (suction is null) 
			OR (conduct_¡ is null) OR (initdef is null);
			
			IF count_aux > 0 THEN
				INSERT INTO audit_check_data (fprocesscat_id, result_id, table_id, column_id, error_message) 
				VALUES (14, result_id_var,'Subcatchments','Various', concat('There are ',count_aux,' with null values on curve number infiltartion method columns (curveno, conduct_2, drytime_2)'));
				count_global_aux=count_global_aux+count_aux; 
				count_aux=0;
			END IF;
		
		
		ELSIF infiltration_aux='HORTON' OR infiltration_aux='MODIFIED_HORTON' THEN
		
			SELECT count(*) INTO count_aux FROM v_edit_subcatchment where (maxrate is null) 
			OR (minrate is null) OR (decay is null) OR (drytime is null) OR (maxinfil is null);
			
			IF count_aux > 0 THEN
				INSERT INTO audit_check_data (fprocesscat_id, result_id, table_id, column_id, error_message) 
				VALUES (14, result_id_var,'Subcatchments','Various', concat('There are ',count_aux,' with null values on Horton/Horton modified infiltartion method columns (maxrate, minrate, decay, drytime, maxinfil)'));
				count_global_aux=count_global_aux+count_aux; 
				count_aux=0;
			END IF;
			
		END IF;
		
		
		SELECT count(*) INTO count_aux FROM v_edit_raingage 
		where (form_type is null) OR (intvl is null) OR (rgage_type is null);
			IF count_aux > 0 THEN
				INSERT INTO audit_check_data (fprocesscat_id, result_id, table_id, column_id, error_message) 
				VALUES (14, result_id_var,'Raingage','Various', concat('There are ',count_aux,' with null values on mandatory columns (form_type, intvl, rgage_type)'));
				count_global_aux=count_global_aux+count_aux; 
				count_aux=0;
			END IF;		
			
		SELECT count(*) INTO count_aux FROM v_edit_raingage where rgage_type='TIMESERIES' AND timser_id IS NULL;
			IF count_aux > 0 THEN
				INSERT INTO audit_check_data (fprocesscat_id, result_id, table_id, column_id, error_message) 
				VALUES (14, result_id_var,'Raingage','timser_id', concat('There are ',count_aux,' with null values on the mandatory column for timeseries raingage type'));
				count_global_aux=count_global_aux+count_aux; 
				count_aux=0;
			END IF;		

		SELECT count(*) INTO count_aux FROM v_edit_raingage where rgage_type='FILE' AND (fname IS NULL) or (sta IS NULL) or (units IS NULL);
			IF count_aux > 0 THEN
				INSERT INTO audit_check_data (fprocesscat_id, result_id, table_id, column_id, error_message) 
				VALUES (14, result_id_var,'Raingage','Various', concat('There are ',count_aux,' with null values on mandatory columns for file raingage type (fname, sta, units)'));
				count_global_aux=count_global_aux+count_aux; 
				count_aux=0;
			END IF;				

	ELSIF project_type_aux='WS' THEN
		--WS check and set value default
		-- nothing
		
		
		-- Check conected nodes but with closed valves -->force to put values of demand on '0'	
		-- TODO
		
				
		-- tanks
		SELECT count(*) INTO count_aux FROM inp_tank JOIN rpt_inp_node ON inp_tank.node_id=rpt_inp_node.node_id 
		WHERE (initlevel IS NULL) OR (minlevel IS NULL) OR (maxlevel IS NULL) OR (diameter IS NULL) OR (minvol IS NULL);
			IF count_aux > 0 THEN
				INSERT INTO audit_check_data (fprocesscat_id, result_id, table_id, column_id, error_message) 
				VALUES (14, result_id_var,'Tank','Various', concat('There are ',count_aux,' with null values on mandatory columns for tank (initlevel, minlevel, maxlevel, diameter, minvol)'));
				count_global_aux=count_global_aux+count_aux; 
				count_aux=0;
			END IF;	
		
		
		-- valve
		SELECT count(*) INTO count_aux FROM inp_valve JOIN rpt_inp_arc ON concat(node_id,_n2a)=arc_id 
		WHERE (valv_type IS NULL) OR (status IS NULL) OR (to_arc IS NULL);
			IF count_aux > 0 THEN
				INSERT INTO audit_check_data (fprocesscat_id, result_id, table_id, column_id, error_message) 
				VALUES (14, result_id_var,'Valve','Various', concat('There are ',count_aux,' with null values on mandatory columns for valve (valv_type, status, to_arc)'));
				count_global_aux=count_global_aux+count_aux; 
				count_aux=0;
			END IF;
		

		SELECT count(*) INTO count_aux FROM inp_valve JOIN rpt_inp_arc ON concat(node_id,_n2a)=arc_id 
		WHERE (valv_type='PBV' OR valv_type='PRV' OR valv_type='PSV') AND (pressure IS NULL);
			IF count_aux > 0 THEN
				INSERT INTO audit_check_data (fprocesscat_id, result_id, table_id, column_id, error_message) 
				VALUES (14, result_id_var,'Valve','pressure', concat('There are ',count_aux,' with null values on the mandatory column for Pressure valves'));
				count_global_aux=count_global_aux+count_aux; 
				count_aux=0;
			END IF;				
	
		SELECT count(*) INTO count_aux FROM inp_valve JOIN rpt_inp_arc ON concat(node_id,_n2a)=arc_id 
		WHERE (valv_type='GPV') AND (curve_id IS NULL);
			IF count_aux > 0 THEN
				INSERT INTO audit_check_data (fprocesscat_id, result_id, table_id, column_id, error_message) 
				VALUES (14, result_id_var,'Valve','curve_id', concat('There are ',count_aux,' with null values on the mandatory column for General purpose valves'));
				count_global_aux=count_global_aux+count_aux; 
				count_aux=0;
			END IF;	

		SELECT count(*) INTO count_aux FROM inp_valve JOIN rpt_inp_arc ON concat(node_id,_n2a)=arc_id 
		WHERE (valv_type='TCV') AND (losses IS NULL);
			IF count_aux > 0 THEN
				INSERT INTO audit_check_data (fprocesscat_id, result_id, table_id, column_id, error_message) 
				VALUES (14, result_id_var,'Valve','losses', concat('There are ',count_aux,' with null values on the mandatory column for Losses valves'));
				count_global_aux=count_global_aux+count_aux; 
				count_aux=0;
			END IF;				

		SELECT count(*) INTO count_aux FROM inp_valve JOIN rpt_inp_arc ON concat(node_id,_n2a)=arc_id 
		WHERE (valv_type='FCV') AND (flow IS NULL);
			IF count_aux > 0 THEN
				INSERT INTO audit_check_data (fprocesscat_id, result_id, table_id, column_id, error_message) 
				VALUES (14, result_id_var,'Valve','flow', concat('There are ',count_aux,' with null values on the mandatory column for Flow control valves'));
				count_global_aux=count_global_aux+count_aux; 
				count_aux=0;
			END IF;				
					
		-- pumps
		SELECT count(*) INTO count_aux FROM inp_pump JOIN rpt_inp_arc ON concat(node_id,_n2a)=arc_id WHERE (curve_id IS NULL) OR (status IS NULL) OR (to_arc IS NULL);
			IF count_aux > 0 THEN
				INSERT INTO audit_check_data (fprocesscat_id, result_id, table_id, column_id, error_message) 
				VALUES (14, result_id_var,'Pump','Various', concat('There are ',count_aux,' with null values on mandatory columns for pump (curve_id, status, to_arc)'));
				count_global_aux=count_global_aux+count_aux; 
				count_aux=0;
			END IF;	
		
		SELECT count(*) INTO count_aux FROM inp_pump_additional JOIN rpt_inp_arc ON concat(node_id,_n2a)=arc_id WHERE (curve_id IS NULL) OR (status IS NULL);
			IF count_aux > 0 THEN
				INSERT INTO audit_check_data (fprocesscat_id, result_id, table_id, column_id, error_message) 
				VALUES (14, result_id_var,'inp_pump_additional','Various', concat('There are ',count_aux,' with null values on mandatory columns for additional pump (curve_id, status)'));
				count_global_aux=count_global_aux+count_aux; 
				count_aux=0;
			END IF;	
	END IF;
	
RETURN count_global_aux;

	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
  
  