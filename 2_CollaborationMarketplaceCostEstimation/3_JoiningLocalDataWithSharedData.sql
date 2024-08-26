-- Set Up a New Database Called INTL_DB
USE ROLE sysadmin;
CREATE DATABASE intl_db;
USE SCHEMA intl_db.public;

-- Create a Warehouse for Loading INTL_DB
USE ROLE sysadmin;

CREATE WAREHOUSE intl_wh 
WITH 
WAREHOUSE_SIZE = 'XSMALL' 
WAREHOUSE_TYPE = 'STANDARD' 
AUTO_SUSPEND = 600 --600 seconds/10 mins
AUTO_RESUME = TRUE;

USE WAREHOUSE intl_wh;


-- Create Table INT_STDS_ORG_3166
CREATE OR REPLACE TABLE intl_db.public.int_stds_org_3166 
(
  iso_country_name VARCHAR(100), 
  country_name_official VARCHAR(200), 
  sovreignty VARCHAR(40), 
  alpha_code_2digit VARCHAR(2), 
  alpha_code_3digit VARCHAR(3), 
  numeric_country_code INTEGER,
  iso_subdivision VARCHAR(15), 
  internet_domain_code VARCHAR(10)
);

-- Create a File Format to Load the Table
CREATE OR REPLACE FILE FORMAT util_db.public.pipe_dblquote_header_cr 
TYPE = 'CSV' --use CSV for any flat file
COMPRESSION = 'AUTO' 
FIELD_DELIMITER = '|' --pipe or vertical bar
RECORD_DELIMITER = '\r' --carriage return
SKIP_HEADER = 1  --1 header row
FIELD_OPTIONALLY_ENCLOSED_BY = '\042'  --double quotes
TRIM_SPACE = FALSE;

-- Load the ISO Table Using Your File Format
/*
Data files for this course are available from an s3 bucket named uni-cmcw.  There is only one s3 bucket in the whole world with that name and it belongs to this course. Create a new stage (you know how! you did it in Badge 1). 

Check to see if you have a stage in your account already (this will be true if you are using the same Trial Account from Badge 1). 
*/
SHOW STAGES IN ACCOUNT; 
/*
You can create a new stage using the wizard, or you can use the code below. 
*/

CREATE STAGE IF NOT EXISTS util_db.public.aws_s3_bucket URL = 's3://uni-cmcw';

/*
Make sure you create it while in the SYSADMIN role, or grant SYSADMIN rights to use the stage. 

The file you will be loading is called iso_countries_utf8_pipe.csv. BUT remember that AWS is very case sensitive, so be sure to look up the EXACT spelling of the file name for your COPY INTO statement. Remember that you can view the files in the stage either by navigating to the stage and enabling the directory table, or by running a list command like this: 
*/
USE ROLE sysadmin;
LIST @util_db.public.aws_s3_bucket;

/*
And finally, here's a reminder of the syntax for COPY INTO:
*/
COPY INTO intl_db.public.int_stds_org_3166 
FROM @util_db.public.aws_s3_bucket
FILES = ( 'ISO_Countries_UTF8_pipe.csv')
FILE_FORMAT = ( FORMAT_NAME='util_db.public.PIPE_DBLQUOTE_HEADER_CR' );  

-- Check That You Created and Loaded the Table Properly
SELECT
  COUNT(*) AS found,
  '249' AS expected 
FROM intl_db.public.int_stds_org_3166; 

-- set your worksheet drop lists or write and run USE commands
-- YOU WILL NEED TO USE ACCOUNTADMIN ROLE on this test.

--DO NOT EDIT BELOW THIS LINE
USE ROLE accountadmin;
USE util_db.public;
SELECT GRADER(step, (actual = expected), actual, expected, description) AS graded_results FROM( 
  SELECT
    'CMCW01' AS step,
    (
      SELECT COUNT(*) 
      FROM snowflake.account_usage.databases
      WHERE database_name = 'INTL_DB' 
        AND deleted IS NULL
    ) AS actual,
    1 AS expected,
    'Created INTL_DB' AS description
);


SELECT
  COUNT(*) AS found,
  '249' AS expected 
FROM intl_db.public.int_stds_org_3166; 

-- How to Test Whether You Set Up Your Table in the Right Place with the Right Name
-- We can "ask" the Information Schema Table called "Tables" if our table exists by asking it to count the number of times a table with that name, in a certain schema, in a certain database (catalog) exists. If it exists, we should get back the count of 1. 
/*
    select count(*) as OBJECTS_FOUND
    from <database name>.INFORMATION_SCHEMA.TABLES 
    where table_schema=<schema name> 
    and table_name= <table name>;
*/

--So if we are looking for INTL_DB.PUBLIC.INT_STDS_ORG_3166 we can run this command to check: 
--Does a table with that name exist...in a certain schema...within a certain database.
SELECT COUNT(*) AS objects_found
FROM intl_db.information_schema.tables 
WHERE table_schema='PUBLIC'
  AND table_name= 'INT_STDS_ORG_3166';

-- How to Test That You Loaded the Expected Number of Rows
-- We can "ask" the Information Schema Table called "Tables" if our table has the expected number of rows with a command like this:
/*
select row_count
from <database name>.INFORMATION_SCHEMA.TABLES 
where table_schema=<schema name> 
and table_name= <table name>;
*/

-- So if we are looking to see how many rows are contained in INTL_DB.PUBLIC.INT_STDS_ORG_3166 we can run this command to check: 
-- For the table we presume exists...in a certain schema...within a certain database...how many rows does the table hold?
SELECT row_count
FROM intl_db.information_schema.tables 
WHERE table_schema='PUBLIC'
  AND table_name= 'INT_STDS_ORG_3166';


-- set your worksheet drop lists to the location of your GRADER function
-- role can be set to either SYSADMIN or ACCOUNTADMIN for this check
USE ROLE accountadmin;
USE util_db.public;
--DO NOT EDIT BELOW THIS LINE
SELECT GRADER(step, (actual = expected), actual, expected, description) AS graded_results FROM(
  SELECT
    'CMCW02' AS step,
    (
      SELECT COUNT(*) 
      FROM intl_db.information_schema.tables 
      WHERE table_schema = 'PUBLIC' 
        AND table_name = 'INT_STDS_ORG_3166'
    ) AS actual,
    1 AS expected,
    'ISO table created' AS description
);

-- DO NOT EDIT BELOW THIS LINE 
SELECT GRADER(step, (actual = expected), actual, expected, description) AS graded_results FROM( 
  SELECT
    'CMCW03' AS step,
    (
      SELECT row_count 
      FROM intl_db.information_schema.tables  
      WHERE table_name = 'INT_STDS_ORG_3166'
    ) AS actual,
    249 AS expected,
    'ISO Table Loaded' AS description 
); 

-- Join Local Data with Shared Data
SELECT  
  iso_country_name,
  country_name_official,
  alpha_code_2digit,
  r_name AS region
FROM intl_db.public.int_stds_org_3166 ASi
LEFT JOIN snowflake_sample_data.tpch_sf1.nation ASn ON UPPER(i.iso_country_name)= n.n_name
LEFT JOIN snowflake_sample_data.tpch_sf1.region ASr ON n_regionkey = r_regionkey;


-- Convert the Select Statement into a View
-- You can convert any SELECT into a VIEW by adding a CREATE VIEW command in front of the SELECT statement
CREATE VIEW intl_db.public.nations_sample_plus_iso 
(
  iso_country_name,
  country_name_official,
  alpha_code_2digit,
  region
) AS
SELECT  
  iso_country_name,
  country_name_official,
  alpha_code_2digit,
  r_name AS region
FROM intl_db.public.int_stds_org_3166 ASi
LEFT JOIN snowflake_sample_data.tpch_sf1.nation ASn ON UPPER(i.iso_country_name)= n.n_name
LEFT JOIN snowflake_sample_data.tpch_sf1.region ASr ON n_regionkey = r_regionkey
;  

-- Run a SELECT on the View You Created
SELECT *
FROM intl_db.public.nations_sample_plus_iso;

-- SET YOUR DROPLISTS PRIOR TO RUNNING THE CODE BELOW 
USE util_db.public;
--DO NOT EDIT BELOW THIS LINE
SELECT GRADER(step, (actual = expected), actual, expected, description) AS graded_results FROM(
  SELECT
    'CMCW04' AS step,
    (
      SELECT COUNT(*) 
      FROM intl_db.public.nations_sample_plus_iso
    ) AS actual,
    249 AS expected,
    'Nations Sample Plus Iso' AS description
);


-- In this challenge lab, you'll create two more tables and another file format, then you'll load the data into the tables. 
-- The files are in your STAGE named aws_s3_bucket.

-- Create Table Currencies
CREATE TABLE intl_db.public.currencies 
(
  currency_id INTEGER, 
  currency_char_code VARCHAR(3), 
  currency_symbol VARCHAR(4), 
  currency_digital_code VARCHAR(3), 
  currency_digital_name VARCHAR(30)
)
COMMENT = 'Information about currencies including character codes, symbols, digital codes, etc.';

-- Create Table Country to Currency
CREATE TABLE intl_db.public.country_code_to_currency_code 
(
  country_char_code VARCHAR(3), 
  country_numeric_code INTEGER, 
  country_name VARCHAR(100), 
  currency_name VARCHAR(100), 
  currency_char_code VARCHAR(3), 
  currency_numeric_code INTEGER
) 
COMMENT = 'Mapping table currencies to countries';

-- Create a File Format to Process files with Commas, Linefeeds and a Header Row
CREATE FILE FORMAT util_db.public.csv_comma_lf_header
TYPE = 'CSV' 
FIELD_DELIMITER = ',' 
RECORD_DELIMITER = '\n' -- the n represents a Line Feed character
SKIP_HEADER = 1 
; 

-- Don't Forget to Load the Data!
-- Now that you've got two tables and two file formats, remember to load the tables with data. 
-- Go back to the top of the page for reminders on how to accomplish the loading. 
USE ROLE accountadmin;
LIST @util_db.public.aws_s3_bucket;

COPY INTO intl_db.public.currencies 
FROM @util_db.public.aws_s3_bucket
FILES = ( 'currencies.csv')
FILE_FORMAT = ( FORMAT_NAME='util_db.public.CSV_COMMA_LF_HEADER' );  

COPY INTO intl_db.public.country_code_to_currency_code 
FROM @util_db.public.aws_s3_bucket
FILES = ( 'country_code_to_currency_code.csv')
FILE_FORMAT = ( FORMAT_NAME='util_db.public.CSV_COMMA_LF_HEADER' );  

USE util_db.public;
--DO NOT EDIT BELOW THIS LINE
SELECT GRADER(step, (actual = expected), actual, expected, description) AS graded_results FROM(
  SELECT
    'CMCW05' AS step,
    (
      SELECT row_count 
      FROM intl_db.information_schema.tables 
      WHERE table_schema = 'PUBLIC' 
        AND table_name = 'COUNTRY_CODE_TO_CURRENCY_CODE'
    ) AS actual,
    265 AS expected,
    'CCTCC Table Loaded' AS description
);

--DO NOT EDIT BELOW THIS LINE
SELECT GRADER(step, (actual = expected), actual, expected, description) AS graded_results FROM(
  SELECT
    'CMCW06' AS step,
    (
      SELECT row_count 
      FROM intl_db.information_schema.tables 
      WHERE table_schema = 'PUBLIC' 
        AND table_name = 'CURRENCIES'
    ) AS actual,
    151 AS expected,
    'Currencies table loaded' AS description
);

-- Create a View that Will Return The Result Set Shown
CREATE OR REPLACE VIEW intl_db.public.simple_currency 
AS
SELECT
  country_char_code AS cty_code,
  currency_char_code AS cur_code
FROM intl_db.public.country_code_to_currency_code
;

USE util_db.public;
--DO NOT EDIT BELOW THIS LINE
SELECT GRADER(step, (actual = expected), actual, expected, description) AS graded_results FROM(
  SELECT
    'CMCW07' AS step,
    (
      SELECT COUNT(*) 
      FROM intl_db.public.simple_currency
    ) AS actual,
    265 AS expected,
    'Simple Currency Looks Good' AS description
);