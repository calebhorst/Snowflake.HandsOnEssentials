-- Set Up a New Database Called INTL_DB
use role SYSADMIN;
create database INTL_DB;
use schema INTL_DB.PUBLIC;

-- Create a Warehouse for Loading INTL_DB
use role SYSADMIN;

create warehouse INTL_WH 
with 
warehouse_size = 'XSMALL' 
warehouse_type = 'STANDARD' 
auto_suspend = 600 --600 seconds/10 mins
auto_resume = TRUE;

use warehouse INTL_WH;


-- Create Table INT_STDS_ORG_3166
create or replace table intl_db.public.INT_STDS_ORG_3166 
(iso_country_name varchar(100), 
 country_name_official varchar(200), 
 sovreignty varchar(40), 
 alpha_code_2digit varchar(2), 
 alpha_code_3digit varchar(3), 
 numeric_country_code integer,
 iso_subdivision varchar(15), 
 internet_domain_code varchar(10)
);

-- Create a File Format to Load the Table
create or replace file format util_db.public.PIPE_DBLQUOTE_HEADER_CR 
  type = 'CSV' --use CSV for any flat file
  compression = 'AUTO' 
  field_delimiter = '|' --pipe or vertical bar
  record_delimiter = '\r' --carriage return
  skip_header = 1  --1 header row
  field_optionally_enclosed_by = '\042'  --double quotes
  trim_space = FALSE;

-- Load the ISO Table Using Your File Format
/*
Data files for this course are available from an s3 bucket named uni-cmcw.  There is only one s3 bucket in the whole world with that name and it belongs to this course. Create a new stage (you know how! you did it in Badge 1). 

Check to see if you have a stage in your account already (this will be true if you are using the same Trial Account from Badge 1). 
*/
show stages in account; 
/*
You can create a new stage using the wizard, or you can use the code below. 
*/

create stage if not exists util_db.public.aws_s3_bucket url = 's3://uni-cmcw';

/*
Make sure you create it while in the SYSADMIN role, or grant SYSADMIN rights to use the stage. 

The file you will be loading is called iso_countries_utf8_pipe.csv. BUT remember that AWS is very case sensitive, so be sure to look up the EXACT spelling of the file name for your COPY INTO statement. Remember that you can view the files in the stage either by navigating to the stage and enabling the directory table, or by running a list command like this: 
*/
use role sysadmin;
list @util_db.public.aws_s3_bucket;

/*
And finally, here's a reminder of the syntax for COPY INTO:
*/
copy into intl_db.public.INT_STDS_ORG_3166 
from @util_db.public.aws_s3_bucket
files = ( 'ISO_Countries_UTF8_pipe.csv')
file_format = ( format_name='util_db.public.PIPE_DBLQUOTE_HEADER_CR' );  

-- Check That You Created and Loaded the Table Properly
select count(*) as found, '249' as expected 
from INTL_DB.PUBLIC.INT_STDS_ORG_3166; 

 -- set your worksheet drop lists or write and run USE commands
-- YOU WILL NEED TO USE ACCOUNTADMIN ROLE on this test.

--DO NOT EDIT BELOW THIS LINE
use role accountadmin;
use util_db.public;
select grader(step, (actual = expected), actual, expected, description) as graded_results from( 
 SELECT 'CMCW01' as step
 ,( select count(*) 
   from snowflake.account_usage.databases
   where database_name = 'INTL_DB' 
   and deleted is null) as actual
 , 1 as expected
 ,'Created INTL_DB' as description
 );


 select count(*) as found, '249' as expected 
from intl_db.public.INT_STDS_ORG_3166; 

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
select count(*) as OBJECTS_FOUND
from INTL_DB.INFORMATION_SCHEMA.TABLES 
where table_schema='PUBLIC'
and table_name= 'INT_STDS_ORG_3166';

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
select row_count
from INTL_DB.INFORMATION_SCHEMA.TABLES 
where table_schema='PUBLIC'
and table_name= 'INT_STDS_ORG_3166';


-- set your worksheet drop lists to the location of your GRADER function
-- role can be set to either SYSADMIN or ACCOUNTADMIN for this check
use role accountadmin;
use util_db.public;
--DO NOT EDIT BELOW THIS LINE
select grader(step, (actual = expected), actual, expected, description) as graded_results from(
SELECT 'CMCW02' as step
 ,( select count(*) 
   from INTL_DB.INFORMATION_SCHEMA.TABLES 
   where table_schema = 'PUBLIC' 
   and table_name = 'INT_STDS_ORG_3166') as actual
 , 1 as expected
 ,'ISO table created' as description
);

-- DO NOT EDIT BELOW THIS LINE 
select grader(step, (actual = expected), actual, expected, description) as graded_results from( 
SELECT 'CMCW03' as step 
 ,(select row_count 
   from INTL_DB.INFORMATION_SCHEMA.TABLES  
   where table_name = 'INT_STDS_ORG_3166') as actual 
 , 249 as expected 
 ,'ISO Table Loaded' as description 
); 

-- Join Local Data with Shared Data
select  
     iso_country_name
    ,country_name_official,alpha_code_2digit
    ,r_name as region
from INTL_DB.PUBLIC.INT_STDS_ORG_3166 i
left join SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.NATION n on upper(i.iso_country_name)= n.n_name
left join SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.REGION r on n_regionkey = r_regionkey;


-- Convert the Select Statement into a View
    -- You can convert any SELECT into a VIEW by adding a CREATE VIEW command in front of the SELECT statement
create view intl_db.public.NATIONS_SAMPLE_PLUS_ISO 
( iso_country_name
  ,country_name_official
  ,alpha_code_2digit
  ,region) AS
select  
     iso_country_name
    ,country_name_official,alpha_code_2digit
    ,r_name as region
from INTL_DB.PUBLIC.INT_STDS_ORG_3166 i
left join SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.NATION n on upper(i.iso_country_name)= n.n_name
left join SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.REGION r on n_regionkey = r_regionkey
;  

-- Run a SELECT on the View You Created
select *
from intl_db.public.NATIONS_SAMPLE_PLUS_ISO;

-- SET YOUR DROPLISTS PRIOR TO RUNNING THE CODE BELOW 
use util_db.public;
--DO NOT EDIT BELOW THIS LINE
select grader(step, (actual = expected), actual, expected, description) as graded_results from(
SELECT 'CMCW04' as step
 ,( select count(*) 
   from INTL_DB.PUBLIC.NATIONS_SAMPLE_PLUS_ISO) as actual
 , 249 as expected
 ,'Nations Sample Plus Iso' as description
);


-- In this challenge lab, you'll create two more tables and another file format, then you'll load the data into the tables. 
-- The files are in your STAGE named aws_s3_bucket.

-- Create Table Currencies
create table intl_db.public.CURRENCIES 
(
  currency_ID integer, 
  currency_char_code varchar(3), 
  currency_symbol varchar(4), 
  currency_digital_code varchar(3), 
  currency_digital_name varchar(30)
)
  comment = 'Information about currencies including character codes, symbols, digital codes, etc.';

-- Create Table Country to Currency
create table intl_db.public.COUNTRY_CODE_TO_CURRENCY_CODE 
  (
    country_char_code varchar(3), 
    country_numeric_code integer, 
    country_name varchar(100), 
    currency_name varchar(100), 
    currency_char_code varchar(3), 
    currency_numeric_code integer
  ) 
  comment = 'Mapping table currencies to countries';

-- Create a File Format to Process files with Commas, Linefeeds and a Header Row
create file format util_db.public.CSV_COMMA_LF_HEADER
  type = 'CSV' 
  field_delimiter = ',' 
  record_delimiter = '\n' -- the n represents a Line Feed character
  skip_header = 1 
; 

-- Don't Forget to Load the Data!
    -- Now that you've got two tables and two file formats, remember to load the tables with data. 
    -- Go back to the top of the page for reminders on how to accomplish the loading. 
use role accountadmin;
list @util_db.public.aws_s3_bucket;

copy into intl_db.public.CURRENCIES 
from @util_db.public.aws_s3_bucket
files = ( 'currencies.csv')
file_format = ( format_name='util_db.public.CSV_COMMA_LF_HEADER' );  

copy into intl_db.public.COUNTRY_CODE_TO_CURRENCY_CODE 
from @util_db.public.aws_s3_bucket
files = ( 'country_code_to_currency_code.csv')
file_format = ( format_name='util_db.public.CSV_COMMA_LF_HEADER' );  

use util_db.public;
--DO NOT EDIT BELOW THIS LINE
select grader(step, (actual = expected), actual, expected, description) as graded_results from(
SELECT 'CMCW05' as step
 ,(select row_count 
  from INTL_DB.INFORMATION_SCHEMA.TABLES 
  where table_schema = 'PUBLIC' 
  and table_name = 'COUNTRY_CODE_TO_CURRENCY_CODE') as actual
 , 265 as expected
 ,'CCTCC Table Loaded' as description
);

--DO NOT EDIT BELOW THIS LINE
select grader(step, (actual = expected), actual, expected, description) as graded_results from(
SELECT 'CMCW06' as step
 ,(select row_count 
  from INTL_DB.INFORMATION_SCHEMA.TABLES 
  where table_schema = 'PUBLIC' 
  and table_name = 'CURRENCIES') as actual
 , 151 as expected
 ,'Currencies table loaded' as description
);

-- Create a View that Will Return The Result Set Shown
create or replace view INTL_DB.PUBLIC.SIMPLE_CURRENCY 
as
select
 COUNTRY_CHAR_CODE as cty_code
 ,CURRENCY_CHAR_CODE as cur_code
from INTL_DB.PUBLIC.COUNTRY_CODE_TO_CURRENCY_CODE
;

use util_db.public;
--DO NOT EDIT BELOW THIS LINE
select grader(step, (actual = expected), actual, expected, description) as graded_results from(
 SELECT 'CMCW07' as step 
,( select count(*) 
  from INTL_DB.PUBLIC.SIMPLE_CURRENCY ) as actual
, 265 as expected
,'Simple Currency Looks Good' as description
);