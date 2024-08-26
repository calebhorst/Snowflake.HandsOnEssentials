-- Create a Table Raw JSON Data
// JSON DDL Scripts
USE DATABASE library_card_catalog;
USE ROLE sysadmin;

// Create an Ingestion Table for JSON Data
CREATE TABLE library_card_catalog.public.author_ingest_json
(
  raw_author VARIANT
);

-- Create a File Format to Load the JSON Data
-- DO NOT USE QUOTES around TRUE and FALSE values. These are boolean, not strings.

//Create File Format for JSON Data 
CREATE FILE FORMAT library_card_catalog.public.json_file_format
TYPE = 'JSON' 
COMPRESSION = 'AUTO' 
ENABLE_OCTAL = FALSE
ALLOW_DUPLICATE = FALSE 
STRIP_OUTER_ARRAY = TRUE
STRIP_NULL_VALUES = FALSE 
IGNORE_UTF8_ERRORS = FALSE
; 
 
-- Load the Data into the New Table, Using the File Format You Created
USE ROLE accountadmin;
SELECT $1
FROM
  @util_db.public.my_internal_stage/author_with_header.json
  (FILE_FORMAT => library_card_catalog.public.json_file_format)
;

COPY INTO library_card_catalog.public.author_ingest_json
FROM @util_db.public.my_internal_stage
FILES = ( 'author_with_header.json')
FILE_FORMAT = ( FORMAT_NAME=library_card_catalog.public.json_file_format )
;    

-- View the JSON Rows
SELECT raw_author
FROM author_ingest_json
;

-- Query the JSON Data
//returns AUTHOR_UID value from top-level object's attribute
SELECT raw_author:AUTHOR_UID
FROM author_ingest_json;

//returns the data in a way that makes it look like a normalized table
SELECT 
  raw_author:AUTHOR_UID,
  raw_author:FIRST_NAME::STRING AS first_name,
  raw_author:MIDDLE_NAME::STRING AS middle_name,
  raw_author:LAST_NAME::STRING AS last_name
FROM author_ingest_json;

-- Set your worksheet drop lists. DO NOT EDIT THE DORA CODE.
USE ROLE accountadmin;
USE util_db.public;
SELECT GRADER(step, (actual = expected), actual, expected, description) AS graded_results FROM
  (
    SELECT
      'DWW16' AS step,
      (
        SELECT row_count 
        FROM library_card_catalog.information_schema.tables 
        WHERE table_name = 'AUTHOR_INGEST_JSON'
      ) AS actual,
      6 AS expected,
      'Check number of rows' AS description
  ); 

