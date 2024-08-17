-- Vegetable Details Table Data
/*
On the next page, you're going to be downloading a file created by Uncle Yer that contains 21 rows. Uncle Yer decided to shorten the words "Deep", "Shallow" and "Medium" to just the first letters. Then he saved the data out to a CSV file. 

CSV stands for Comma Separated Values. This means that his file separates the values by inserting a comma in between each value in the row.  If you open a CSV file in Excel or Google Sheets, those programs will interpret the commas as separators (hiding them from you) and displaying the values in different columns. 

Instead of opening with Excel or Sheets, be sure to open the file with a simple text editor like Notepad or BBEdit. Then you will see the commas that are separating the values in the rows. It is important to know how to look at a file using a simple text editor because sometimes characters other than commas are used to separate the values in a file.  
*/

-- Create a Vegetable Details Table

use role sysadmin;
create table garden_plants.veggies.vegetable_details
(
plant_name varchar(25)
, root_depth_code varchar(1)    
);

-- Upload the File Into Your Veggie Details Table!
    -- Used Web UI
SELECT *
FROM GARDEN_PLANTS.VEGGIES.VEGETABLE_DETAILS
LIMIT 10;

-- Challenge Lab:  Load A SECOND FILE into the Table
    -- Used Web UI
SELECT *
FROM GARDEN_PLANTS.VEGGIES.VEGETABLE_DETAILS
;
-- If you accidentally load the same file twice and want to start over, run a TRUNCATE command to empty out the table. 
-- TRUNCATE TABLE GARDEN_PLANTS.VEGGIES.VEGETABLE_DETAILS;

--Set your worksheet drop list role to ACCOUNTADMIN
--Set your worksheet drop list database and schema to the location of your GRADER function

-- DO NOT EDIT ANYTHING BELOW THIS LINE. THE CODE MUST BE RUN EXACTLY AS IT IS WRITTEN
use role accountadmin;
use util_db.public;
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from (
 SELECT 'DWW06' as step
 ,( select count(*) 
   from GARDEN_PLANTS.INFORMATION_SCHEMA.TABLES 
   where table_name = 'VEGETABLE_DETAILS') as actual
 , 1 as expected
 ,'VEGETABLE_DETAILS Table' as description
); 

-- View Your Vegetable Details Table
use role sysadmin;
select *
from garden_plants.veggies.vegetable_details
where plant_name  = 'Spinach'
;

delete 
from garden_plants.veggies.vegetable_details
where plant_name  = 'Spinach'
and root_depth_code = 'D'
;

select count(1) as count_distinct_recs_by_plant_name
from garden_plants.veggies.vegetable_details
group by plant_name
having count_distinct_recs_by_plant_name > 1
;
-- QUERY PRODUCED NO RESULTS (assert only 1 record per plant_name)


--Set your worksheet drop list role to ACCOUNTADMIN
--Set your worksheet drop list database and schema to the location of your GRADER function
use role accountadmin;
use util_db.public;
-- DO NOT EDIT ANYTHING BELOW THIS LINE. THE CODE MUST BE RUN EXACTLY AS IT IS WRITTEN
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from (
 SELECT 'DWW07' as step
 ,( select row_count 
   from GARDEN_PLANTS.INFORMATION_SCHEMA.TABLES 
   where table_name = 'VEGETABLE_DETAILS') as actual
 , 41 as expected
 , 'VEG_DETAILS row count' as description
); 

