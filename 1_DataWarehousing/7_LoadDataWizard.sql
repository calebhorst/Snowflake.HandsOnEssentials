-- Vegetable Details Table Data
/*
On the next page, you're going to be downloading a file created by Uncle Yer that contains 21 rows. Uncle Yer decided to shorten the words "Deep", "Shallow" and "Medium" to just the first letters. Then he saved the data out to a CSV file. 

CSV stands for Comma Separated Values. This means that his file separates the values by inserting a comma in between each value in the row.  If you open a CSV file in Excel or Google Sheets, those programs will interpret the commas as separators (hiding them from you) and displaying the values in different columns. 

Instead of opening with Excel or Sheets, be sure to open the file with a simple text editor like Notepad or BBEdit. Then you will see the commas that are separating the values in the rows. It is important to know how to look at a file using a simple text editor because sometimes characters other than commas are used to separate the values in a file.  
*/

-- Create a Vegetable Details Table

USE ROLE sysadmin;
CREATE TABLE garden_plants.veggies.vegetable_details
(
  plant_name VARCHAR(25),
  root_depth_code VARCHAR(1)    
);

-- Upload the File Into Your Veggie Details Table!
-- Used Web UI
SELECT *
FROM garden_plants.veggies.vegetable_details
LIMIT 10;

-- Challenge Lab:  Load A SECOND FILE into the Table
-- Used Web UI
SELECT *
FROM garden_plants.veggies.vegetable_details
;
-- If you accidentally load the same file twice and want to start over, run a TRUNCATE command to empty out the table. 
-- TRUNCATE TABLE GARDEN_PLANTS.VEGGIES.VEGETABLE_DETAILS;

--Set your worksheet drop list role to ACCOUNTADMIN
--Set your worksheet drop list database and schema to the location of your GRADER function

-- DO NOT EDIT ANYTHING BELOW THIS LINE. THE CODE MUST BE RUN EXACTLY AS IT IS WRITTEN
USE ROLE accountadmin;
USE util_db.public;
SELECT GRADER(step, (actual = expected), actual, expected, description) AS graded_results FROM (
  SELECT
    'DWW06' AS step,
    (
      SELECT COUNT(*) 
      FROM garden_plants.information_schema.tables 
      WHERE table_name = 'VEGETABLE_DETAILS'
    ) AS actual,
    1 AS expected,
    'VEGETABLE_DETAILS Table' AS description
); 

-- View Your Vegetable Details Table
USE ROLE sysadmin;
SELECT *
FROM garden_plants.veggies.vegetable_details
WHERE plant_name  = 'Spinach'
;

DELETE 
FROM garden_plants.veggies.vegetable_details
WHERE plant_name  = 'Spinach'
  AND root_depth_code = 'D'
;

SELECT COUNT(1) AS count_distinct_recs_by_plant_name
FROM garden_plants.veggies.vegetable_details
GROUP BY plant_name
HAVING count_distinct_recs_by_plant_name > 1
;
-- QUERY PRODUCED NO RESULTS (assert only 1 record per plant_name)


--Set your worksheet drop list role to ACCOUNTADMIN
--Set your worksheet drop list database and schema to the location of your GRADER function
USE ROLE accountadmin;
USE util_db.public;
-- DO NOT EDIT ANYTHING BELOW THIS LINE. THE CODE MUST BE RUN EXACTLY AS IT IS WRITTEN
SELECT GRADER(step, (actual = expected), actual, expected, description) AS graded_results FROM (
  SELECT
    'DWW07' AS step,
    (
      SELECT row_count 
      FROM garden_plants.information_schema.tables 
      WHERE table_name = 'VEGETABLE_DETAILS'
    ) AS actual,
    41 AS expected,
    'VEG_DETAILS row count' AS description
); 

