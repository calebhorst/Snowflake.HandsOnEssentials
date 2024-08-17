-- Create a Table Raw JSON Data
// JSON DDL Scripts
use database library_card_catalog;
use role sysadmin;

// Create an Ingestion Table for JSON Data
create table library_card_catalog.public.author_ingest_json
(
  raw_author variant
);

-- Create a File Format to Load the JSON Data
-- DO NOT USE QUOTES around TRUE and FALSE values. These are boolean, not strings.

//Create File Format for JSON Data 
create file format library_card_catalog.public.json_file_format
    type = 'JSON' 
    compression = 'AUTO' 
    enable_octal = FALSE
    allow_duplicate = FALSE 
    strip_outer_array = true
    strip_null_values = FALSE 
    ignore_utf8_errors = FALSE
; 
 
-- Load the Data into the New Table, Using the File Format You Created
use role accountadmin;
select $1
from @util_db.public.my_internal_stage/author_with_header.json
(file_format => library_card_catalog.public.json_file_format)
;

copy into library_card_catalog.public.author_ingest_json
from @util_db.public.my_internal_stage
files = ( 'author_with_header.json')
file_format = ( format_name=library_card_catalog.public.json_file_format )
;    

-- View the JSON Rows
select raw_author
from author_ingest_json
;

-- Query the JSON Data
//returns AUTHOR_UID value from top-level object's attribute
select raw_author:AUTHOR_UID
from author_ingest_json;

//returns the data in a way that makes it look like a normalized table
SELECT 
 raw_author:AUTHOR_UID
,raw_author:FIRST_NAME::STRING as FIRST_NAME
,raw_author:MIDDLE_NAME::STRING as MIDDLE_NAME
,raw_author:LAST_NAME::STRING as LAST_NAME
FROM AUTHOR_INGEST_JSON;

-- Set your worksheet drop lists. DO NOT EDIT THE DORA CODE.
use role accountadmin;
use util_db.public;
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from
(
  SELECT 'DWW16' as step
  ,( select row_count 
    from LIBRARY_CARD_CATALOG.INFORMATION_SCHEMA.TABLES 
    where table_name = 'AUTHOR_INGEST_JSON') as actual
  ,6 as expected
  ,'Check number of rows' as description
 ); 

