-- Copy the CREATE TABLE Code from the VEGETABLE_DETAILS Table
use role sysadmin;
create table garden_plants.flowers.flower_details
(
plant_name varchar(25)
, root_depth_code varchar(1)    
);

select *
from garden_plants.flowers.flower_details
;

-- Create a Snowflake Notebook & Add a Markdown Cell

-- Delete the Example Cells

-- Add a SQL Cell & Name It
insert into garden_plants.flowers.flower_details
select 'Petunia','M';

-- Create a New Cell & Fill It with a Select *
/*
- Create another SQL Cell
- Name it "check_the_table"
- Write a SELECT * statement on the flower_detail table
- Run the cell
*/

-- Create Two More Cells & Reorder the Cells 
/*
- Create 3 More SQL Cells
- Name one "set_flower_name" (empty for now)
- Name another "set_root_depth_code" (empty for now)
- Name the 3rd cell "check_my_variables" (empty for now)
- Rearrange the cells using the methods shown in UI steps
*/

-- Fill In the New SQL Cells and Run Them
set rdc = 'S';
set fn = 'Lilac';

-- Replace the Flower Name & Root Depth Code with the Variables
select $fn, $rdc;

-- Run the Last Cell to Check Your Insert
select *
from garden_plants.flowers.flower_details
;

-- Edit Your Markdown Cell


-- Use Your Notebook to Create 3 Additional Rows in the Flower Detail Table
/*
- A Sunflower should have deep roots. 
- Lavender can have shallow roots.
- A Tulip has a bulb, not roots, but we'll say they need medium root depth. 
*/

--  Run the Last Cell to Check Your Inserted Rows

--Set your worksheet drop list role to ACCOUNTADMIN
--Set your worksheet drop list database and schema to the location of your GRADER function
use role accountadmin;
use util_db.public;

-- DO NOT EDIT ANYTHING BELOW THIS LINE. THE CODE MUST BE RUN EXACTLY AS IT IS WRITTEN
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from ( 
   SELECT 'DWW08' as step 
   ,( select iff(count(*)=0, 0, count(*)/count(*))
      from table(information_schema.query_history())
      where query_text like 'execute notebook%Uncle Yer%') as actual 
   , 1 as expected 
   , 'Notebook success!' as description 
); 

-- Create a Fruit Details Table - Model it After the Other 2 Details Tables
use role sysadmin;
create table garden_plants.fruits.fruit_details
(
plant_name varchar(25)
, root_depth_code varchar(1)    
);
-- Create a Streamlit-in-Snowflake Data Entry Form

-- Delete Most of the Sample Code
-- On the code side of the screen, delete all code from line 18 to the end. Then click 'Run" in the upper left corner.

-- Edit the Form Title & Instruction Line

-- Add Input Fields
st.text_input('Fruit Name:')
st.selectbox('Root Depth:', ('S','M','D'))

-- Add Variables to Capture Input
/*
Remember that with our notebook we declared two variables. 
For the fruit name we named our variable "fn" and for our root depth code we named our variable "rdc."
*/

-- Set Variables fn and rdc
    -- Make changes to the code so that whatever is entered into the Fruit Name field is stored in a variable named fn.
    -- Make changes to the code so that whatever is chosen from the Root Depth select box is stored in a variable named rdc. 

-- Add a Submit Button
if st.button('Submit'):
    st.write('Fruit Name entered is ' + fn)
    st.write('Root Depth Code chosen is ' + rdc)

-- Prepare to Write the Data to the Database
Add these lines as part of the if block.

 sql_insert = 'insert into garden_plants.fruits.fruit_details select '+fn+','+rdc
 st.write(sql_insert)    

-- Escape Characters
/*
To build our insert statements, we used some strings and some variables. In between the strings and variables we had the + symbol. The string parts were enclosed in single quotes. But now we need to add single quotes to the output. How can we tell Python which single quote characters are enclosing our strings and which ones we want as part of the strings? 

In coding, the way to distinguish between a symbol that is performing a job (like enclosing a string) and a symbol that needs to be part of the output is to put an ESCAPE CHARACTER in front of it. 

An escape character means "the next character you see is meant to be taken literally. It is not performing a job here."

In Python the escape character is a back slash. 

So the code below is confusing to Python: 

my_greeting_string = 'Hello ma'am'
But adding the backslash to the word ma'am makes sense:

my_greeting_string = 'Hello ma\'am'
The quote in front of the "H" and the quote after the "m" are performing the job of enclosing the greeting. The quote in the middle of ma'am is part of the greeting. 
*/ 

-- Run the SQL and See a Results Message
-- Comment out the line st.write(sql_insert)
Add these two lines then Run the app (and click the Submit button): 
result = session.sql(sql_insert)
st.write(result)

-- Check Your Fruit Details Table & Add More Rows
; --mixed python and sql code in this sheet
select *
from garden_plants.fruits.fruit_details
;

-- Once you have confirmed that your app works, add two more rows (for a total of 3 rows).
    -- You can use any fruit names you want with any root depth settings. 

--Set your worksheet drop list role to ACCOUNTADMIN
--Set your worksheet drop list database and schema to the location of your GRADER function
use role accountadmin;
use util_db.public;

-- DO NOT EDIT ANYTHING BELOW THIS LINE. THE CODE MUST BE RUN EXACTLY AS IT IS WRITTEN
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from (
 SELECT 'DWW09' as step
 ,( select count(*)/count(*) 
    from snowflake.account_usage.query_history
    where query_text like 'execute streamlit "GARDEN_PLANTS"."FRUITS".%'
   ) as actual
 , 1 as expected
 ,'SiS App Works' as description
);     