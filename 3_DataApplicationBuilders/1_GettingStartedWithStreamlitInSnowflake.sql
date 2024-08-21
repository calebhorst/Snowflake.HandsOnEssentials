/*
🎯 Check Your Warehouse 
You should know how to complete the tasks below in Snowflake (because you've completed Badges 1 and 2!)  
All Trial Accounts should come with an XS Warehouse named COMPUTE_WH. Sometimes this is not the case. Please take a moment to check and make sure you have a COMPUTE_WH warehouse and check that SYSADMIN owns it.

    - If you don't have the COMPUTE_WH warehouse, please create it. 
    - If the warehouse is owned by ACCOUNTADMIN, change the ownership to SYSADMIN

🎯 Create a Smoothies Database
    - Create a new database in your trial account.
    - Call it SMOOTHIES.
    - Make sure it is owned by the SYSADMIN Role. 
- The PUBLIC schema will also need to be owned by SYSADMIN. 

🎯 Configure Your User Profile
    - Click on the up arrow next to your name in the bottom-left corner of the main screen.
    - Choose My profile.
    - Set your default role to SYSADMIN (if needed).
    - Set your default warehouse to COMPUTE_WH (if needed).
    - In the Notifications section, check the box that will make sure you get emails when a resource monitor wants to alert you. 
*/

-- Check Your Warehouse 
use role sysadmin;

create warehouse if not exists compute_wh
warehouse_size = 'XSMALL'
;

use role accountadmin;
grant ownership on warehouse compute_wh to role sysadmin;

-- Create a Smoothies Database
use role sysadmin;
create or replace database smoothies;
use database smoothies;
grant ownership on schema public to role sysadmin;

-- Set your default role to SYSADMIN (if needed).
-- Set your default warehouse to COMPUTE_WH (if needed).
alter user calebhorst set default_role = sysadmin;
alter user calebhorst set default_warehouse = compute_wh;

-- Create Your Smoothie Order Form SIS App
/*
    NOTE: DOUBLE-CHECK that you are using SYSADMIN when you create your Streamlit APP!! You cannot easliy change ownership of a Streamlit app AFTER it is created. 
*/

/*
🎯 Create a FRUIT_OPTIONS Table
- Create a table called FRUIT_OPTIONS in the PUBLIC schema of your SMOOTHIES database.
- Make sure it owned by the SYSADMIN Role. 
- The table should have two columns:
    - First column should be named FRUIT_ID and hold a number. 
    - Second column should be named FRUIT_NAME and hold text up to 25 characters long. 
*/
use role sysadmin;
create table if not exists smoothies.public.fruit_options(
    fuit_id number(38,0)
    ,fruit_name varchar(25)
)
;

/*
📓 The File We Need to Load 
We noticed two things about the file:

1) There are two header rows. 
2) The column delimiter is a % sign. 

We need to build a FILE FORMAT with those two things in mind. 
*/

-- 🥋 A FILE FORMAT to Load the Fruit File
create file format smoothies.public.two_headerrow_pct_delim
   type = CSV,
   skip_header = 2,   
   field_delimiter = '%',
   trim_space = TRUE
;

-- 🥋 Create the Internal Stage and Load the File Into It
create stage if not exists smoothies.public.my_uploaded_files
encryption = (TYPE = 'SNOWFLAKE_SSE')
comment = 'streamlit demo';

-- 🥋 Check to See if the File WOULD load.
copy into smoothies.public.fruit_options
from @smoothies.public.my_uploaded_files
files = ('fruits_available_for_smoothies.txt')
file_format = (format_name = smoothies.public.two_headerrow_pct_delim)
on_error = abort_statement
validation_mode = return_errors
purge = false;

-- 🥋 Query the Not-Yet-Loaded Data Using the File Format
select $1, $2
from @smoothies.public.my_uploaded_files
(file_format => smoothies.public.two_headerrow_pct_delim)
;

-- 🥋 Reorder Columns During the COPY INTO LOAD
-- The Snowflake DOCS cover the topic here: https://docs.snowflake.com/en/user-guide/data-load-transform#reorder-csv-columns-during-a-load
copy into smoothies.public.fruit_options
from (
    select $2 as fruit_id, $1 as fruit_name
    from @smoothies.public.my_uploaded_files
)
files = ('fruits_available_for_smoothies.txt')
file_format = (format_name = smoothies.public.two_headerrow_pct_delim)
on_error = abort_statement
purge = true;

-- 🥋 Display the Fruit Options List in Your Streamlit in Snowflake (SiS) App. 
--Navigate back to your SiS App and add the bit of code included below. 

/*
session = get_active_session()
my_dataframe = session.table("smoothies.public.fruit_options")
st.dataframe(data=my_dataframe, use_container_width=True)
*/

-- 🧰  Check that DORA is Working In Your Current Trial Account
/*
You should have already set DORA up for this trial account. If you have not, complete the followings steps:

Confirm you have a UTIL_DB owned by SYSADMIN. (or create it). 
Confirm you have a PUBLIC schema in your UTIL_DB that is owned by SYSADMIN (or create it, or transfer the ownership)
Click on the DORA link at the top of this page and follow the directions to create the API integration and GRADER function. 
*/
-- 🤖 Is DORA Working? Run This to Find Out!
use util_db.public;
-- Remember that you MUST USE ACCOUNTADMIN and UTIL_DB.PUBLIC as your context anytime you run DORA checks!!
-- DO NOT EDIT ANYTHING BELOW THIS LINE
select grader(step, (actual = expected), actual, expected, description) as graded_results from 
  ( SELECT 
  'DORA_IS_WORKING' as step
 ,(select 223) as actual
 , 223 as expected
 ,'Dora is working!' as description
); 


-- Set your worksheet drop lists
-- DO NOT EDIT ANYTHING BELOW THIS LINE
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from (
  SELECT 'DABW001' as step
 ,( select count(*) 
   from SMOOTHIES.PUBLIC.FRUIT_OPTIONS) as actual
 , 25 as expected
 ,'Fruit Options table looks good' as description
);
