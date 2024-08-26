-- Create Your ROOT_DEPTH Table
USE ROLE sysadmin;
CREATE OR REPLACE TABLE garden_plants.veggies.root_depth (
  root_depth_id NUMBER(1),
  root_depth_code TEXT(1),
  root_depth_name TEXT(7),
  unit_of_measure TEXT(2),
  range_min NUMBER(2),
  range_max NUMBER(2)
);

-- Find the Table You Just Created by Worksheets Object Picker in the Worksheets Sidebar
DESC TABLE garden_plants.veggies.root_depth;

-- View the Definition of Your Table
SELECT GET_DDL('table', 'garden_plants.veggies.root_depth');

-- Insert One Row into Your ROOT_DEPTH Table Using the Insert Statement Below
USE WAREHOUSE compute_wh;
USE garden_plants.veggies;

INSERT INTO root_depth (
  root_depth_id,
  root_depth_code,
  root_depth_name,
  unit_of_measure,
  range_min,
  range_max
)
VALUES
(
  1,
  'S',
  'Shallow',
  'cm',
  30,
  45
)
;

SELECT *
FROM garden_plants.veggies.root_depth;

-- Learning About Select Stars & Limits
SELECT *
FROM root_depth
LIMIT 1;

-- Add Two More Rows to the ROOT_DEPTH Table
INSERT INTO root_depth (
  root_depth_id,
  root_depth_code,
  root_depth_name,
  unit_of_measure,
  range_min,
  range_max
)
VALUES
(
  2,
  'M',
  'Medium',
  'cm',
  45,
  60
),
(
  3,
  'D',
  'Deep',
  'cm',
  60,
  90
)
;

SELECT *
FROM garden_plants.veggies.root_depth;


-- New to SQL? Need Some Help? Check Out the Code Samples Below
--THESE ARE JUST EXAMPLES YOU SHOULD NOT RUN THIS CODE WITHOUT EDITING IT FOR YOUR NEEDS

--To add more than one row at a time
INSERT INTO root_depth (
  root_depth_id, root_depth_code,
  root_depth_name, unit_of_measure,
  range_min, range_max
)
VALUES
(5, 'X', 'short', 'in', 66, 77),
(8, 'Y', 'tall', 'cm', 98, 99)
;

-- To remove a row you do not want in the table
DELETE FROM root_depth
WHERE root_depth_id = 9;

--To change a value in a column for one particular row
UPDATE root_depth
SET root_depth_id = 7
WHERE root_depth_id = 9;

--To remove all the rows and start over
TRUNCATE TABLE root_depth;