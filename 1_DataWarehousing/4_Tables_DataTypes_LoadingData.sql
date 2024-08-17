-- Create Your ROOT_DEPTH Table
use role sysadmin;
create or replace table GARDEN_PLANTS.VEGGIES.ROOT_DEPTH (
   ROOT_DEPTH_ID number(1), 
   ROOT_DEPTH_CODE text(1), 
   ROOT_DEPTH_NAME text(7), 
   UNIT_OF_MEASURE text(2),
   RANGE_MIN number(2),
   RANGE_MAX number(2)
); 

-- Find the Table You Just Created by Worksheets Object Picker in the Worksheets Sidebar
desc table garden_plants.veggies.root_depth;

-- View the Definition of Your Table
select get_ddl('table', 'garden_plants.veggies.root_depth');

-- Insert One Row into Your ROOT_DEPTH Table Using the Insert Statement Below
USE WAREHOUSE COMPUTE_WH;
use garden_plants.veggies;

INSERT INTO ROOT_DEPTH (
	ROOT_DEPTH_ID ,
	ROOT_DEPTH_CODE ,
	ROOT_DEPTH_NAME ,
	UNIT_OF_MEASURE ,
	RANGE_MIN ,
	RANGE_MAX 
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

select *
from garden_plants.veggies.root_depth;

-- Learning About Select Stars & Limits
SELECT *
FROM ROOT_DEPTH
LIMIT 1;

-- Add Two More Rows to the ROOT_DEPTH Table
INSERT INTO ROOT_DEPTH (
	ROOT_DEPTH_ID ,
	ROOT_DEPTH_CODE ,
	ROOT_DEPTH_NAME ,
	UNIT_OF_MEASURE ,
	RANGE_MIN ,
	RANGE_MAX 
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

select *
from garden_plants.veggies.root_depth;


-- New to SQL? Need Some Help? Check Out the Code Samples Below
--THESE ARE JUST EXAMPLES YOU SHOULD NOT RUN THIS CODE WITHOUT EDITING IT FOR YOUR NEEDS

--To add more than one row at a time
insert into root_depth (root_depth_id, root_depth_code
                        , root_depth_name, unit_of_measure
                        , range_min, range_max)  
values
 (5,'X','short','in',66,77)
,(8,'Y','tall','cm',98,99)
;

-- To remove a row you do not want in the table
delete from root_depth
where root_depth_id = 9;

--To change a value in a column for one particular row
update root_depth
set root_depth_id = 7
where root_depth_id = 9;

--To remove all the rows and start over
truncate table root_depth;