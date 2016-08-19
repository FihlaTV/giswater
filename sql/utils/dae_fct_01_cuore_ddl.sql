/*
This file is part of Giswater 2.0
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/



SET search_path = "SCHEMA_NAME", public, pg_catalog;



-- Catalog of table
DROP TABLE IF EXISTS SCHEMA_NAME.db_cat_table CASCADE; 
CREATE TABLE SCHEMA_NAME.db_cat_table (
    id int4 PRIMARY KEY,
    name text NOT NULL,
    project_type text,
    context text,
	db_cat_clientlayer_id int4,
	description text
);



-- Catalog of views
DROP TABLE IF EXISTS SCHEMA_NAME.db_cat_view CASCADE; 
CREATE TABLE SCHEMA_NAME.db_cat_view (
    id int4 PRIMARY KEY,
    name text NOT NULL,
	project_type text,
    context text,
	db_cat_clientlayer_id int4,
	description text
);


-- Catalog of columns
DROP TABLE IF EXISTS SCHEMA_NAME.db_cat_columns CASCADE; 
CREATE TABLE SCHEMA_NAME.db_cat_columns (
    id int4 PRIMARY KEY,
	db_cat_table_id int4 NOT NULL,
    column_name text NOT NULL,
	column_type text,
	description text
);



-- Catalog of client layer
DROP TABLE IF EXISTS SCHEMA_NAME.db_cat_clientlayer CASCADE; 
CREATE TABLE SCHEMA_NAME.db_cat_clientlayer (
    id int4 PRIMARY KEY,
    name text NOT NULL,
	group_level_1 text,
	group_level_2 text,
	group_level_3 text,
	description text
);


ALTER TABLE SCHEMA_NAME.db_cat_table ADD FOREIGN KEY ("db_cat_clientlayer_id") REFERENCES SCHEMA_NAME.db_cat_clientlayer ("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE SCHEMA_NAME.db_cat_view ADD FOREIGN KEY ("db_cat_clientlayer_id") REFERENCES SCHEMA_NAME.db_cat_clientlayer ("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE SCHEMA_NAME.db_cat_columns ADD FOREIGN KEY ("db_cat_table_id") REFERENCES SCHEMA_NAME.db_cat_table ("id") ON DELETE CASCADE ON UPDATE CASCADE;




