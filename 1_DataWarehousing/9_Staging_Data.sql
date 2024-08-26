-- Create a Snowflake Stage Object
USE ROLE accountadmin;
CREATE STAGE IF NOT EXISTS util_db.public.my_internal_stage
  ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE')
  COMMENT = 'a place to hold files before loading them';

--Set your worksheet drop list role to ACCOUNTADMIN
--Set your worksheet drop list database and schema to the location of your GRADER function
USE ROLE accountadmin;
USE SCHEMA public;

-- DO NOT EDIT ANYTHING BELOW THIS LINE. THE CODE MUST BE RUN EXACTLY AS IT IS WRITTEN
SELECT GRADER(step, (actual = expected), actual, expected, description) AS graded_results FROM (
  SELECT
    'DWW10' AS step,
    (
      SELECT COUNT(*) 
      FROM util_db.information_schema.stages
      WHERE stage_name='MY_INTERNAL_STAGE' 
        AND stage_type IS NULL
    ) AS actual,
    1 AS expected,
    'Internal stage created' AS description
); 


-- To COPY INTO statement, it is best to have 4 things in place:
/*
- A table 
- A stage object
- A file
- A file format 
The file format is sort of optional, but it's a cleaner process if you have one, and we do!
*/

COPY INTO my_table_name
FROM @my_internal_stage
FILES = ( 'IF_I_HAD_A_FILE_LIKE_THIS.txt')
FILE_FORMAT = ( FORMAT_NAME='EXAMPLE_FILEFORMAT' );

--You already have your stage, and you have a file loaded into that stage. All you need now is a table and a file format. Once you have those, you'll be able to run a COPY INTO statement.

-- Create a Table for Soil Types
USE ROLE sysadmin;
CREATE OR REPLACE TABLE garden_plants.veggies.vegetable_details_soil_type
(
  plant_name VARCHAR(25),
  soil_type NUMBER(1,0)
);

-- Create a File Format
USE ROLE accountadmin;
CREATE FILE FORMAT garden_plants.veggies.pipecolsep_oneheadrow 
TYPE = 'CSV'--csv is used for any flat file (tsv, pipe-separated, etc)
FIELD_DELIMITER = '|' --pipes as column separators
SKIP_HEADER = 1 --one header row to skip
;

-- A Copy Into Statement You Can Run
COPY INTO garden_plants.veggies.vegetable_details_soil_type
FROM @util_db.public.my_internal_stage
FILES = ( 'VEG_NAME_TO_SOIL_TYPE_PIPE.txt')
FILE_FORMAT = ( FORMAT_NAME=garden_plants.veggies.pipecolsep_oneheadrow );    


--Set your worksheet drop list role to ACCOUNTADMIN
--Set your worksheet drop list database and schema to the location of your GRADER function
USE ROLE accountadmin;
USE SCHEMA public;
-- DO NOT EDIT ANYTHING BELOW THIS LINE. THE CODE MUST BE RUN EXACTLY AS IT IS WRITTEN
SELECT GRADER(step, (actual = expected), actual, expected, description) AS graded_results FROM (
  SELECT
    'DWW11' AS step,
    (
      SELECT row_count 
      FROM garden_plants.information_schema.tables 
      WHERE table_name = 'VEGETABLE_DETAILS_SOIL_TYPE'
    ) AS actual,
    42 AS expected,
    'Veg Det Soil Type Count' AS description
); 

-- Create Another File Format
CREATE FILE FORMAT garden_plants.veggies.commasep_dblquot_oneheadrow 
TYPE = 'CSV'--csv for comma separated files
FIELD_DELIMITER = ',' --commas as column separators
SKIP_HEADER = 1 --one header row  
FIELD_OPTIONALLY_ENCLOSED_BY = '"' --this means that some values will be wrapped in double-quotes bc they have commas in them
;

-- Explore the Effect of File Formats On Data Interpretation
--The data in the file, with no FILE FORMAT specified
SELECT $1
FROM @util_db.public.my_internal_stage/LU_SOIL_TYPE.tsv;

--Same file but with one of the file formats we created earlier  
SELECT
  $1,
  $2,
  $3
FROM
  @util_db.public.my_internal_stage/LU_SOIL_TYPE.tsv
  (FILE_FORMAT => garden_plants.veggies.commasep_dblquot_oneheadrow);

--Same file but with the other file format we created earlier
SELECT
  $1,
  $2,
  $3
FROM
  @util_db.public.my_internal_stage/LU_SOIL_TYPE.tsv
  (FILE_FORMAT => garden_plants.veggies.pipecolsep_oneheadrow );

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
CREATE OR REPLACE FILE FORMAT garden_plants.veggies.l9_challenge_ff 
TYPE = 'CSV'--csv for comma separated files
FIELD_DELIMITER = '\t' --commas as column separators
SKIP_HEADER = 1 --one header row  
FIELD_OPTIONALLY_ENCLOSED_BY = '"' --this means that some values will be wrapped in double-quotes bc they have commas in them
;

SELECT
  $1,
  $2,
  $3
FROM
  @util_db.public.my_internal_stage/LU_SOIL_TYPE.tsv
  (FILE_FORMAT => garden_plants.veggies.l9_challenge_ff);

-- Create a Soil Type Look Up Table
USE ROLE sysadmin;
CREATE OR REPLACE TABLE garden_plants.veggies.lu_soil_type(
  soil_type_id NUMBER,	
  soil_type VARCHAR(15),
  soil_description VARCHAR(75)
);

-- Create a COPY INTO Statement to Load the File into the Table
/*
1. Create a COPY INTO command to load the file (LU_SOIL_TYPE.tsv ) from your stage to the LU_SOIL_TYPE table.
2. Load the table by running the COPY INTO command you wrote.  DO NOT use 'SKIP_FILE' or 'CONTINUE' for the ON_ERROR option, even if the system suggests it. 
3. Run a SELECT * on the table to see if loaded nicely. 
4. If it didn't, truncate the table, fix the file format (or COPY INTO) and load it again. 
*/

USE ROLE accountadmin;
COPY INTO garden_plants.veggies.lu_soil_type
FROM @util_db.public.my_internal_stage
FILES = ( 'LU_SOIL_TYPE.tsv')
FILE_FORMAT = ( FORMAT_NAME=garden_plants.veggies.l9_challenge_ff  );

SELECT *
FROM garden_plants.veggies.lu_soil_type
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

CREATE TABLE IF NOT EXISTS garden_plants.veggies.vegetable_details_plant_height(
  plant_name VARCHAR,
  uom VARCHAR,
  low_end_of_range NUMBER(38,0),
  high_end_of_range NUMBER(38,0)
);

COPY INTO garden_plants.veggies.vegetable_details_plant_height
FROM @util_db.public.my_internal_stage
FILES = ( 'veg_plant_height.csv')
FILE_FORMAT = ( FORMAT_NAME=garden_plants.veggies.commasep_dblquot_oneheadrow  );

SELECT *
FROM garden_plants.veggies.vegetable_details_plant_height
;

--Set your worksheet drop list role to ACCOUNTADMIN
--Set your worksheet drop list database and schema to the location of your GRADER function
USE ROLE accountadmin;
USE util_db.public;
-- DO NOT EDIT ANYTHING BELOW THIS LINE. THE CODE MUST BE RUN EXACTLY AS IT IS WRITTEN
SELECT GRADER(step, (actual = expected), actual, expected, description) AS graded_results FROM (  
  SELECT
    'DWW12' AS step,
    (
      SELECT row_count 
      FROM garden_plants.information_schema.tables 
      WHERE table_name = 'VEGETABLE_DETAILS_PLANT_HEIGHT'
    ) AS actual,
    41 AS expected,
    'Veg Detail Plant Height Count' AS description   
); 

--Set your worksheet drop list role to ACCOUNTADMIN
--Set your worksheet drop list database and schema to the location of your GRADER function

-- DO NOT EDIT ANYTHING BELOW THIS LINE. THE CODE MUST BE RUN EXACTLY AS IT IS WRITTEN
SELECT GRADER(step, (actual = expected), actual, expected, description) AS graded_results FROM (  
  SELECT
    'DWW13' AS step,
    (
      SELECT row_count 
      FROM garden_plants.information_schema.tables 
      WHERE table_name = 'LU_SOIL_TYPE'
    ) AS actual,
    8 AS expected,
    'Soil Type Look Up Table' AS description   
); 

-- Set your worksheet drop lists
-- DO NOT EDIT THE CODE 
SELECT GRADER(step, (actual = expected), actual, expected, description) AS graded_results FROM ( 
  SELECT
    'DWW14' AS step,
    (
      SELECT COUNT(*) 
      FROM garden_plants.information_schema.file_formats 
      WHERE file_format_name='L9_CHALLENGE_FF' 
        AND field_delimiter = '\t'
    ) AS actual,
    1 AS expected,
    'Challenge File Format Created' AS description  
); 