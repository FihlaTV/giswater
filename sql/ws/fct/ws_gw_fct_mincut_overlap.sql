﻿/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: 2244

DROP FUNCTION IF EXISTS SCHEMA_NAME.gw_fct_mincut_result_overlap(integer, text);
CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_fct_mincut_result_overlap(result_id_arg integer, cur_user_var text)
  RETURNS boolean AS
$BODY$
DECLARE
    mincut_rec		record;
    mincut_macexpl_aux  integer;
    overlap_rec	 	record;
    id_last		integer;
    overlap_macexpl_aux integer;
    overlap_exists_bool	boolean;
    comp_overlap_bool	boolean;
    conflict_id_text   	text;
    query_text 		text;
    count_int		integer;
    count_result_int	integer;
    conflict_exists	boolean;

BEGIN

    -- Search path
    SET search_path = "SCHEMA_NAME", public;

    -- init variables;
    overlap_exists_bool:=FALSE;
    comp_overlap_bool:=FALSE;
    conflict_exists:=FALSE;
    SELECT count(*) INTO count_int FROM anl_mincut_result_arc WHERE result_id=result_id_arg;
    
    -- starting process
    SELECT * INTO mincut_rec FROM anl_mincut_result_cat WHERE id=result_id_arg;

    -- timedate overlap control
    FOR overlap_rec IN SELECT * FROM anl_mincut_result_cat 
    WHERE (forecast_start, forecast_end) OVERLAPS (mincut_rec.forecast_start, mincut_rec.forecast_end) AND id !=result_id_arg
    LOOP
	-- if exist timedate overlap
  	IF overlap_rec.id IS NOT NULL THEN
  	        
		-- macroexploitation overlap control
		SELECT macroexpl_id INTO overlap_macexpl_aux FROM exploitation WHERE expl_id=overlap_rec.expl_id;

		-- if exists macroexpl overlap		
		IF overlap_macexpl_aux=mincut_rec.macroexpl_id THEN

			-- if it's first time
			IF overlap_exists_bool IS FALSE THEN

				-- create temp result for joined analysis
				INSERT INTO anl_mincut_result_cat (work_order, mincut_state, mincut_class, expl_id, macroexpl_id) 
				VALUES ('Conflict', 2, 1, mincut_rec.expl_id, mincut_rec.macroexpl_id) RETURNING id INTO id_last;

				-- copying proposed valves and afected arcs from original mincut result to temp result  into anl_mincut_result_valve 
                                query_text:='INSERT INTO anl_mincut_result_valve (result_id, node_id,  closed,  broken, unaccess, proposed, the_geom)
				             SELECT '||id_last||', node_id,  closed,  broken, unaccess, proposed, the_geom 
				             FROM anl_mincut_result_valve WHERE result_id='||result_id_arg||' AND proposed=TRUE';
				EXECUTE query_text;

				query_text:='INSERT INTO anl_mincut_result_arc ( result_id, arc_id, the_geom)
				             SELECT '||id_last||', arc_id, the_geom 
				             FROM anl_mincut_result_arc WHERE result_id='||result_id_arg;
				EXECUTE query_text;

				--identifing overlaping
				overlap_exists_bool:= TRUE;
			END IF;

			-- copying proposed valves and afected arcs from overlaped mincut result 
			query_text:='INSERT INTO anl_mincut_result_valve ( result_id, node_id,  closed,  broken, unaccess, proposed, the_geom)
				     SELECT '||id_last||', node_id,  closed,  broken, unaccess, proposed, the_geom 
				     FROM anl_mincut_result_valve WHERE result_id='||overlap_rec.id||' AND proposed=TRUE';     
			EXECUTE query_text;

			query_text:='INSERT INTO anl_mincut_result_arc ( result_id, arc_id, the_geom)
			             SELECT '||id_last||', arc_id, the_geom 
			             FROM anl_mincut_result_arc WHERE result_id='||overlap_rec.id;    
			EXECUTE query_text;	

			-- count arc_id afected on the overlaped mincut result
			count_int:=count_int+(SELECT count(*) FROM anl_mincut_result_arc WHERE result_id=overlap_rec.id);
			conflict_id_text:=concat(conflict_id_text,' ',overlap_rec.id);
			
		END IF;
	END IF;
    END LOOP;

    IF overlap_exists_bool THEN

		-- call mincut_flowtrace function
		raise notice 'Execute mincut again overlaping valves';
		PERFORM gw_fct_mincut_inverted_flowtrace (id_last);

		count_result_int:=(SELECT count(*) FROM anl_mincut_result_arc WHERE result_id=id_last) ;

		raise notice 'v1 %, v2 %', count_int, count_result_int;

		-- Update result valves with two dry sides to proposed=false
		UPDATE anl_mincut_result_valve SET proposed=FALSE WHERE result_id=result_id_arg AND node_id IN
		(
			SELECT node_1 FROM anl_mincut_result_arc JOIN arc ON anl_mincut_result_arc.arc_id=arc.arc_id 
			JOIN anl_mincut_result_valve ON node_id=node_1 WHERE anl_mincut_result_arc.result_id=id_last AND proposed IS TRUE
				INTERSECT
			SELECT node_2 FROM anl_mincut_result_arc JOIN arc ON anl_mincut_result_arc.arc_id=arc.arc_id 
			JOIN anl_mincut_result_valve ON node_id=node_2 WHERE anl_mincut_result_arc.result_id=id_last AND proposed IS TRUE
		);
	
		-- compare results from original againts overlaped result
		
		IF count_int != count_result_int THEN
			-- update workcat on cat table
			UPDATE anl_mincut_result_cat SET work_order=concat('Conflict: ',result_id_arg,' vs',conflict_id_text) WHERE id=id_last;	

			-- Showing conflictive arcs
			DELETE FROM anl_mincut_result_arc WHERE arc_id IN (SELECT arc_id FROM anl_mincut_result_arc WHERE result_id=result_id_arg) AND result_id=id_last;

			--update selector
			DELETE FROM "anl_mincut_result_selector" where cur_user=cur_user_var;
			INSERT INTO "anl_mincut_result_selector" (result_id, cur_user) VALUES (id_last, cur_user_var);
			conflict_exists:=TRUE;
		ELSE 
			DELETE FROM  anl_mincut_result_cat WHERE id=id_last;
			
		END IF;

   END IF;


RETURN conflict_exists;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;