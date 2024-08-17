-- Create a Snowflake Stage Object
use role accountadmin;
create stage if not exists util_db.public.my_internal_stage
encryption = (TYPE = 'SNOWFLAKE_SSE')
comment = 'a place to hold files before loading them';

--Set your worksheet drop list role to ACCOUNTADMIN
--Set your worksheet drop list database and schema to the location of your GRADER function
use role accountadmin;
use schema public;

-- DO NOT EDIT ANYTHING BELOW THIS LINE. THE CODE MUST BE RUN EXACTLY AS IT IS WRITTEN
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from (
 SELECT 'DWW10' as step
  ,( select count(*) 
    from UTIL_DB.INFORMATION_SCHEMA.stages
    where stage_name='MY_INTERNAL_STAGE' 
    and stage_type is null) as actual
  , 1 as expected
  , 'Internal stage created' as description
 ); 


 -- To COPY INTO statement, it is best to have 4 things in place:
/*
- A table 
- A stage object
- A file
- A file format 
The file format is sort of optional, but it's a cleaner process if you have one, and we do!
*/

copy into my_table_name
from @my_internal_stage
files = ( 'IF_I_HAD_A_FILE_LIKE_THIS.txt')
file_format = ( format_name='EXAMPLE_FILEFORMAT' );

--You already have your stage, and you have a file loaded into that stage. All you need now is a table and a file format. Once you have those, you'll be able to run a COPY INTO statement.

-- Create a Table for Soil Types
use role sysadmin;
create or replace table GARDEN_PLANTS.veggies.vegetable_details_soil_type
( plant_name varchar(25)
 ,soil_type number(1,0)
);

-- Create a File Format
use role accountadmin;
create file format garden_plants.veggies.PIPECOLSEP_ONEHEADROW 
    type = 'CSV'--csv is used for any flat file (tsv, pipe-separated, etc)
    field_delimiter = '|' --pipes as column separators
    skip_header = 1 --one header row to skip
    ;

-- A Copy Into Statement You Can Run
copy into GARDEN_PLANTS.veggies.vegetable_details_soil_type
from @util_db.public.my_internal_stage
files = ( 'VEG_NAME_TO_SOIL_TYPE_PIPE.txt')
file_format = ( format_name=GARDEN_PLANTS.VEGGIES.PIPECOLSEP_ONEHEADROW );    


--Set your worksheet drop list role to ACCOUNTADMIN
--Set your worksheet drop list database and schema to the location of your GRADER function
use role accountadmin;
use schema public;
-- DO NOT EDIT ANYTHING BELOW THIS LINE. THE CODE MUST BE RUN EXACTLY AS IT IS WRITTEN
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from (
  SELECT 'DWW11' as step
  ,( select row_count 
    from GARDEN_PLANTS.INFORMATION_SCHEMA.TABLES 
    where table_name = 'VEGETABLE_DETAILS_SOIL_TYPE') as actual
  , 42 as expected
  , 'Veg Det Soil Type Count' as description
 ); 

 -- Create Another File Format
create file format garden_plants.veggies.COMMASEP_DBLQUOT_ONEHEADROW 
    TYPE = 'CSV'--csv for comma separated files
    FIELD_DELIMITER = ',' --commas as column separators
    SKIP_HEADER = 1 --one header row  
    FIELD_OPTIONALLY_ENCLOSED_BY = '"' --this means that some values will be wrapped in double-quotes bc they have commas in them
    ;

-- Explore the Effect of File Formats On Data Interpretation
--The data in the file, with no FILE FORMAT specified
select $1
from @util_db.public.my_internal_stage/LU_SOIL_TYPE.tsv;

--Same file but with one of the file formats we created earlier  
select $1, $2, $3
from @util_db.public.my_internal_stage/LU_SOIL_TYPE.tsv
(file_format => garden_plants.veggies.COMMASEP_DBLQUOT_ONEHEADROW);

--Same file but with the other file format we created earlier
select $1, $2, $3
from @util_db.public.my_internal_stage/LU_SOIL_TYPE.tsv
(file_format => garden_plants.veggies.PIPECOLSEP_ONEHEADROW );

-- Do You Have What It Takes? Do You WANT this Badge BAD ENOUGH? 
    -- Neither of the file formats used above seem like the right file format to load this TSV file. 
    -- It's time for you to challenge yourself to figure out the magic combination of file format settings that WILL LOAD THE FILE CORRECTLY. 

-- Create a File Format That Makes the Data Look Great
/*
1. Before you loaded the TSV file to your stage, you downloaded it to your local machine. Open the local file and LOOK at the file structure. Use a good text editor (NOT EXCEL, NOT GOOGLE SHEETS).
    -- Do you see any issues in the data?  Do not edit the data. We want you to create a file format that can handle the file's data without any direct file edits. 
2. Create a file format that will help you load files with these properties. Name the file format: L9_CHALLENGE_FF
3. Make sure the data looks like the screenshot below when you use your new File Format in the query. 

-- TIPS and TRICKS 
    - All flat files are loaded using file formats that have a type of CSV (Comma Separated Values). So, use TYPE = CSV for any flat file (TSV, Pipe Delimited, .txt, etc.).
    - The FIELD_DELIMITER property is very important. It should match the actual Column Separator being used in the file. 
    - Once you create your FILE FORMAT, if you want to edit it, just add OR REPLACE to the code (as in CREATE OR REPLACE FILE FORMAT) and you will be editing the file format by re-defining it. 
    - It is possible to load the data without creating the file format, but as you might have guessed, DORA will be looking for the L9_CHALLENGE_FF file format. 
    - If columns in a file were separated by a tab, you would put FIELD_DELIMITER = '\t' as a property in the file format you created. 
*/
create or replace file format garden_plants.veggies.L9_CHALLENGE_FF 
    TYPE = 'CSV'--csv for comma separated files
    FIELD_DELIMITER = '\t' --commas as column separators
    SKIP_HEADER = 1 --one header row  
    FIELD_OPTIONALLY_ENCLOSED_BY = '"' --this means that some values will be wrapped in double-quotes bc they have commas in them
    ;

select $1, $2, $3
from @util_db.public.my_internal_stage/LU_SOIL_TYPE.tsv
(file_format => garden_plants.veggies.L9_CHALLENGE_FF);

-- Create a Soil Type Look Up Table
use role sysadmin;
create or replace table GARDEN_PLANTS.VEGGIES.LU_SOIL_TYPE(
SOIL_TYPE_ID number,	
SOIL_TYPE varchar(15),
SOIL_DESCRIPTION varchar(75)
 );

-- Create a COPY INTO Statement to Load the File into the Table
/*
1. Create a COPY INTO command to load the file (LU_SOIL_TYPE.tsv ) from your stage to the LU_SOIL_TYPE table.
2. Load the table by running the COPY INTO command you wrote.  DO NOT use 'SKIP_FILE' or 'CONTINUE' for the ON_ERROR option, even if the system suggests it. 
3. Run a SELECT * on the table to see if loaded nicely. 
4. If it didn't, truncate the table, fix the file format (or COPY INTO) and load it again. 
*/

use role accountadmin;
copy into GARDEN_PLANTS.veggies.LU_SOIL_TYPE
from @util_db.public.my_internal_stage
files = ( 'LU_SOIL_TYPE.tsv')
file_format = ( format_name=garden_plants.veggies.L9_CHALLENGE_FF  );

select *
from GARDEN_PLANTS.veggies.LU_SOIL_TYPE
;

-- Choose a File Format, write the COPY INTO, Load the File into the Table
/*
    1. Look at the data. Do not edit the data. Just look to understand it.  
    2. Create a table called VEGETABLE_DETAILS_PLANT_HEIGHT in the VEGGIES schema. Use the header row of the file to get your column names. Choose good data types for each column. 
    3. Upload the file into your stage.
    4. Choose an existing file format (one you already created) that you think can be used to load the data.
    5. Use a COPY INTO command to load the file from the Stage to the table you created. 
NOTE: The most common error is "Number of columns in file (1) does not match that of the corresponding table (4)" if you see this message, you have not chosen the correct file format. Or, sometimes, you are trying to load the wrong file. Double-check the file, file format, and table to make sure they match up. 
*/

create table if not exists garden_plants.veggies.VEGETABLE_DETAILS_PLANT_HEIGHT(
    plant_name varchar
    ,UOM varchar
    ,Low_End_of_Range number(38,0)
    ,High_End_of_Range number(38,0)
);

copy into GARDEN_PLANTS.veggies.VEGETABLE_DETAILS_PLANT_HEIGHT
from @util_db.public.my_internal_stage
files = ( 'veg_plant_height.csv')
file_format = ( format_name=garden_plants.veggies.COMMASEP_DBLQUOT_ONEHEADROW  );

select *
from garden_plants.veggies.VEGETABLE_DETAILS_PLANT_HEIGHT
;

--Set your worksheet drop list role to ACCOUNTADMIN
--Set your worksheet drop list database and schema to the location of your GRADER function
use role accountadmin;
use util_db.public;
-- DO NOT EDIT ANYTHING BELOW THIS LINE. THE CODE MUST BE RUN EXACTLY AS IT IS WRITTEN
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from (  
      SELECT 'DWW12' as step 
      ,( select row_count 
        from GARDEN_PLANTS.INFORMATION_SCHEMA.TABLES 
        where table_name = 'VEGETABLE_DETAILS_PLANT_HEIGHT') as actual 
      , 41 as expected 
      , 'Veg Detail Plant Height Count' as description   
); 

--Set your worksheet drop list role to ACCOUNTADMIN
--Set your worksheet drop list database and schema to the location of your GRADER function

-- DO NOT EDIT ANYTHING BELOW THIS LINE. THE CODE MUST BE RUN EXACTLY AS IT IS WRITTEN
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from (  
     SELECT 'DWW13' as step 
     ,( select row_count 
       from GARDEN_PLANTS.INFORMATION_SCHEMA.TABLES 
       where table_name = 'LU_SOIL_TYPE') as actual 
     , 8 as expected 
     ,'Soil Type Look Up Table' as description   
); 

-- Set your worksheet drop lists
-- DO NOT EDIT THE CODE 
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from ( 
     SELECT 'DWW14' as step 
     ,( select count(*) 
       from GARDEN_PLANTS.INFORMATION_SCHEMA.FILE_FORMATS 
       where FILE_FORMAT_NAME='L9_CHALLENGE_FF' 
       and FIELD_DELIMITER = '\t') as actual 
     , 1 as expected 
     ,'Challenge File Format Created' as description  
); 