-- The VIN Data Infrastructure on the ACME Side
use role sysadmin;
-- Create New Objects in ACME
create database if not exists stock;
drop schema if exists public;
create schema if not exists unsold;

-- ACME's Lot Stock Table
--Caden needs a table that stores the ACME Car Inventory
create or replace table stock.unsold.lotstock
(
  vin varchar(25)
, exterior varchar(50)	
, interior varchar(50)
, manuf_name varchar(25)
, vehicle_type varchar(25)
, make_name varchar(25)
, plant_name varchar(25)
, model_year varchar(25)
, model_name varchar(25)
, desc1 varchar(25)
, desc2 varchar(25)
, desc3 varchar(25)
, desc4 varchar(25)
, desc5 varchar(25)
, engine varchar(25)
, drive_type varchar(25)
, transmission varchar(25)
, mpg varchar(25)
);

-- Look at the File ACME Receives from their Vehicle Delivery Company
/*
The file is located in a stage. The same stage you used to load Max's file. 

The problem is that you haven't created a stage on the ACME account, yet.

You need a Stage in ACME that points to the same S3 bucket as the stage you created  in the ADU account. 

*/
-- Create a stage named aws_s3_bucket in the STOCK.UNSOLD schema of the ACME account. 
create stage if not exists STOCK.UNSOLD.aws_s3_bucket url = 's3://uni-cmcw';

list @STOCK.UNSOLD.aws_s3_bucket;

-- Fill in the rest of the file name by looking at the files in your new stage
-- Replace the question marks with the file name (remember AWS is case sensitive)
select $1, $2, $3
from @stock.unsold.aws_s3_bucket/Lotties_LotStock_Data.csv
;

-- Create a File Format for ACME
/*
Create a file format named CSV_COMMA_LF_HEADER in the UTIL_DB.PUBLIC schema of the ACME account. 
Make sure it is owned by SYSADMIN.
It will be exactly like the file format you created in Lesson 3 on the 🎯 Create a Few More Tables and Load Them page.
But if you'd like to create the File Format yourself, use these settings:


type = 'CSV'
field_delimiter = ',' 
record_delimiter = '\n'  --Line feed
skip_header = 1 
*/
create file format util_db.public.CSV_COMMA_LF_HEADER
  type = 'CSV' 
  field_delimiter = ',' 
  record_delimiter = '\n' -- the n represents a Line Feed character
  skip_header = 1 
; 

-- Query the File Again, with the Help of a File Format
-- Replace the question marks with the file name (remember AWS is case sensitive)
-- Notice that we use AS to rename the columns and we are now using a file format 
-- The file format knows to skip the first row because it is a header row
select $1 as VIN
, $2 as Exterior, $3 as Interior
from @stock.unsold.aws_s3_bucket/Lotties_LotStock_Data.csv
(file_format => util_db.public.csv_comma_lf_header);

-- How to Load a File of 3 Columns into a Table of 18 Columns?
/*
Did you notice that the file we are loading only has 3 columns or fields? The VIN, the Exterior Colors and the Interior Colors are the columns in our file. The other columns in the table will be empty until we use Max's DECODE functionality to populate them. 

To load our file into our table, we'll need a new File Format with two new properties. 

We'll replace the SKIP_HEADER property with a PARSE_HEADER property. This will tell Snowflake to look at that first row and use it to figure out the column names. 

We'll also add a ERROR_ON_COLUMN_COUNT_MISMATCH property. By setting this property FALSE, we'll be telling Snowflake that it's fine if the file has 3 columns but the table has 18. 
*/

-- Another File Format
-- This file format will allow the 3 column file to be loaded into an 18 column table
-- By parsing the header, Snowflake can infer the column names
CREATE FILE FORMAT util_db.public.CSV_COL_COUNT_DIFF 
type = 'CSV' 
field_delimiter = ',' 
record_delimiter = '\n' 
field_optionally_enclosed_by = '"'
trim_space = TRUE
error_on_column_count_mismatch = FALSE
parse_header = TRUE;


-- With a parsed header, Snowflake can MATCH BY COLUMN NAME during the COPY INTO
copy into stock.unsold.lotstock
from @stock.unsold.aws_s3_bucket/Lotties_LotStock_Data.csv
file_format = (format_name = util_db.public.csv_col_count_diff)
match_by_column_name='CASE_INSENSITIVE';

select *
from stock.unsold.lotstock;



-- Run the UDTF
--If ACME Can't see the tables and their data, how can they run the function that uses those tables and their data!
select * 
from table(ADU_VIN.DECODE.PARSE_AND_ENHANCE_VIN('5UXCR6C0XL9C77256'));

--A simple select from Lot Stock (choose any VIN from the LotStock table)
select * 
from stock.unsold.lotstock
where vin = 'SADCL2GX2LA620676';

-- here we use ls for lotstock table and pf for parse function
-- this more complete statement lets us combine the data already in the table 
-- with the data returned from the parse function
select ls.vin, ls.exterior, ls.interior, pf.*
from
(select * 
from table(ADU_VIN.DECODE.PARSE_AND_ENHANCE_VIN('5J8YD4H86LL013641'))
) pf
join stock.unsold.lotstock ls
where pf.vin = ls.vin;
;

-- Use a Variable Instead
-- We can use a local (session) variable to make it easier to change the VIN we are trying to enhance
set my_vin = 'SADCL2GX2LA620676';

select $my_vin;
select ls.vin, pf.manuf_name, pf.vehicle_type
        , pf.make_name, pf.plant_name, pf.model_year
        , pf.desc1, pf.desc2, pf.desc3, pf.desc4, pf.desc5
        , pf.engine, pf.drive_type, pf.transmission, pf.mpg
from stock.unsold.lotstock ls
join 
    (   select 
          vin, manuf_name, vehicle_type
        , make_name, plant_name, model_year
        , desc1, desc2, desc3, desc4, desc5
        , engine, drive_type, transmission, mpg
        from table(ADU_VIN.DECODE.PARSE_AND_ENHANCE_VIN($my_vin))
    ) pf
on pf.vin = ls.vin;

-- Don't Just Select It, Store It!
-- We're using "s" for "source." The joined data from the LotStock table and the parsing function will be a source of data for us. 
-- We're using "t" for "target." The LotStock table is the target table we want to update.
 
update stock.unsold.lotstock t
set manuf_name = s.manuf_name
, vehicle_type = s.vehicle_type
, make_name = s.make_name
, plant_name = s.plant_name
, model_year = s.model_year
, desc1 = s.desc1
, desc2 = s.desc2
, desc3 = s.desc3
, desc4 = s.desc4
, desc5 = s.desc5
, engine = s.engine
, drive_type = s.drive_type
, transmission = s.transmission
, mpg = s.mpg
from 
(
    select ls.vin, pf.manuf_name, pf.vehicle_type
        , pf.make_name, pf.plant_name, pf.model_year
        , pf.desc1, pf.desc2, pf.desc3, pf.desc4, pf.desc5
        , pf.engine, pf.drive_type, pf.transmission, pf.mpg
    from stock.unsold.lotstock ls
    join 
    (   select 
          vin, manuf_name, vehicle_type
        , make_name, plant_name, model_year
        , desc1, desc2, desc3, desc4, desc5
        , engine, drive_type, transmission, mpg
        from table(ADU_VIN.DECODE.PARSE_AND_ENHANCE_VIN($my_vin))
    ) pf
    on pf.vin = ls.vin
) s
where t.vin = s.vin;

-- Setting a Variable with a SQL Query
-- We can count the number of rows in the LotStock table that have not yet been updated.  
 
set row_count = (select count(*) 
                from stock.unsold.lotstock
                where manuf_name is null);

select $row_count;


set row_count = (select count(*) 
                from stock.unsold.lotstock
                where manuf_name is null);

select $row_count;

-- Combining the Table Data with the Function Data
-- This scripting block runs very slow, but it shows how blocks work for people who are new to using them
DECLARE
    update_stmt varchar(2000);
    res RESULTSET;
    cur CURSOR FOR select vin from stock.unsold.lotstock where manuf_name is null;
BEGIN
    OPEN cur;
    FOR each_row IN cur DO
        update_stmt := 'update stock.unsold.lotstock t '||
            'set manuf_name = s.manuf_name ' ||
            ', vehicle_type = s.vehicle_type ' ||
            ', make_name = s.make_name ' ||
            ', plant_name = s.plant_name ' ||
            ', model_year = s.model_year ' ||
            ', desc1 = s.desc1 ' ||
            ', desc2 = s.desc2 ' ||
            ', desc3 = s.desc3 ' ||
            ', desc4 = s.desc4 ' ||
            ', desc5 = s.desc5 ' ||
            ', engine = s.engine ' ||
            ', drive_type = s.drive_type ' ||
            ', transmission = s.transmission ' ||
            ', mpg = s.mpg ' ||
            'from ' ||
            '(       select ls.vin, pf.manuf_name, pf.vehicle_type ' ||
                    ', pf.make_name, pf.plant_name, pf.model_year ' ||
                    ', pf.desc1, pf.desc2, pf.desc3, pf.desc4, pf.desc5 ' ||
                    ', pf.engine, pf.drive_type, pf.transmission, pf.mpg ' ||
                'from stock.unsold.lotstock ls ' ||
                'join ' ||
                '(   select' || 
                '     vin, manuf_name, vehicle_type' ||
                '    , make_name, plant_name, model_year ' ||
                '    , desc1, desc2, desc3, desc4, desc5 ' ||
                '    , engine, drive_type, transmission, mpg ' ||
                '    from table(ADU_VIN.DECODE.PARSE_AND_ENHANCE_VIN(\'' ||
                  each_row.vin || '\')) ' ||
                ') pf ' ||
                'on pf.vin = ls.vin ' ||
            ') s ' ||
            'where t.vin = s.vin;';
        res := (EXECUTE IMMEDIATE :update_stmt);
    END FOR;
    CLOSE cur;   
END;



-- This test will not work until one day after you set up your ACME Account.
select *
from snowflake.organization_usage.accounts
;

-- set the worksheet drop lists to match the location of your GRADER function
--DO NOT MAKE ANY CHANGES BELOW THIS LINE
use role accountadmin;
use util_db.public;
--RUN THIS DORA CHECK IN YOUR ORIGINAL TRIAL ACCOUNT
select grader(step, (actual = expected), actual, expected, description) as graded_results from ( SELECT 'CMCW12' as step ,( select count(*) from SNOWFLAKE.ORGANIZATION_USAGE.ACCOUNTS where account_name = 'ACME' 
 and region like 'AZURE_%' and deleted_on is null) as actual , 1 as expected ,'ACME Account Added on Azure Platform' as description ); 

 -- This test will not work until at least 24 hours after you set up your ADU Account. A few people have reported it taking 48 hours. 

--🤖 ADU Account Added
-- set the worksheet drop lists to match the location of your GRADER function
--DO NOT MAKE ANY CHANGES BELOW THIS LINE

--RUN THIS DORA CHECK IN YOUR ORIGINAL TRIAL ACCOUNT

select grader(step, (actual = expected), actual, expected, description) as graded_results from (
SELECT 
  'CMCW13' as step
 ,( select count(*) 
   from SNOWFLAKE.ORGANIZATION_USAGE.ACCOUNTS 
   where account_name = 'AUTO_DATA_UNLIMITED' 
   and region like 'GCP_%'
   and deleted_on is null) as actual
 , 1 as expected
 ,'ADU Account Added on GCP' as description
); 

-- set the worksheet drop lists to match the location of your GRADER function
--DO NOT MAKE ANY CHANGES BELOW THIS LINE

--RUN THIS DORA CHECK IN YOUR ACME ACCOUNT

select grader(step, (actual = expected), actual, expected, description) as graded_results from (
SELECT 
  'CMCW14' as step
 ,( select count(*) 
   from STOCK.UNSOLD.LOTSTOCK
   where engine like '%.5 L%'
   or plant_name like '%z, Sty%'
   or desc2 like '%xDr%') as actual
 , 145 as expected
 ,'Intentionally cryptic test' as description
); 