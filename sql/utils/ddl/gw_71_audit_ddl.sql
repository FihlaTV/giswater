/*
This file is part of Giswater 2.0
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


-- An audit history is important on most tables. Provide an audit trigger that logs to
-- a dedicated audit table for the major relations.
-- This code is generic and not depend on application roles or structures. Is based on:
--   http://wiki.postgresql.org/wiki/Audit_trigger_91plus

SET search_path = "SCHEMA_NAME", public, pg_catalog;


-- Catalog of functions
DROP TABLE IF EXISTS audit_cat_function CASCADE; 
CREATE TABLE audit_cat_function (
    id int4 PRIMARY KEY,
    name text NOT NULL,
    function_type text,
    context text,
    input_params json, 
    return_type text
);



-- Catalog of errors
DROP TABLE IF EXISTS audit_cat_error CASCADE;  
CREATE TABLE audit_cat_error (
    id integer PRIMARY KEY,
    error_message text,
    hint_message text,
    log_level int2 CHECK (log_level IN (0,1,2,3)) DEFAULT 1,
    show_user boolean DEFAULT 'True',
    context text DEFAULT 'generic'
);



DROP TABLE IF EXISTS audit_function_actions CASCADE; 
CREATE TABLE IF NOT EXISTS audit_function_actions (
    id bigserial PRIMARY KEY,
    tstamp TIMESTAMP NOT NULL DEFAULT date_trunc('second', current_timestamp), 
    audit_cat_error_id integer NOT NULL,
    audit_cat_function_id int4,
    query text,
    user_name text,
    addr inet,
    debug_info text
);

