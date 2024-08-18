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

 