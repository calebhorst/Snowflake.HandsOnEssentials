-- Exploring the Data and App in Your Trial Account

--  Exploring the Source of the Databases
/*
When we navigate to to the Shared Data page, we gain some insight into the source of our databases.

Notice that the database called SNOWFLAKE_SAMPLE_DATA is coming from an account called SFSALESSHARED (followed by a schema that will vary by region).

This account named their outbound share "SAMPLE_DATA." 

It is only in our account that this data appears under the name SNOWFLAKE_SAMPLE_DATA.
*/

/*
-- The Account Usage Share
Every Snowflake account has THE SNOWFLAKE database included in the account. This database sometimes has a database icon, but sometimes has an app icon.

But let's pause for a minute here. The name of the database is SNOWFLAKE?

When we talk about THE SNOWFLAKE database it can be confusing. After all, there are many Snowflake databases. Are we talking about A Snowflake database (any database in Snowflake) or THE Snowflake Database (the one shared with us BY Snowflake the Company, called SNOWFLAKE)? 

For this reason, people at Snowflake often fall into the habit of calling it "the Account Usage Share" -- because it's a share given to every account and behind the scenes it's based on a direct share called ACCOUNT_USAGE. Originally, the Account Usage Share had one schema called ACCOUNT_USAGE  and not much else. Over time, it's come to include other schemas that are intended to help customers manage and understand their billing and usage. 
*/

-- Dropping the Sample Data Database
use role accountadmin;
drop database snowflake_sample_data;

-- View Changes to the Private Sharing Page 
    -- If the blue download button doesn't appear on the SAMPLE_DATA listing, just refresh the page (top right corner under the [Share] button. If that doesn't work, use the browser refresh button. 

-- Adding the Sample Data Back (I named it as SFK_SAMPLE_DATA)
    -- Web UI
    -- Once the database appears in your account again, you may need to wait 10-15 seconds for the data to show up. Feel free to refresh as needed. 

-- Create a SQL Worksheet & Name It "CMCW Lesson 2"
-- Setting the Sample Share Name Back to the Original Name
alter database SFK_SAMPLE_DATA
rename to snowflake_sample_data;

/*
Challenge Lab: What Can You Do to the SNOWFLAKE Database?
Now that you've carried out a lot of actions on the SNOWFLAKE_SAMPLE_DATA database, can you take similar actions with the SNOWFLAKE database (a.k.a. The Account Usage share)?

Can you drop that database? Can you add it back with a different name? Can you run an ALTER statement to rename it?

HINT: There's a chance the Account Usage Share is a one-of-a-kind share and doesn't play by the same rules as the sample data share. 
*/

-- What Databases Can You See as SYSADMIN?
    -- Remember Dropping and Adding the Sample Database?
    -- We did not give any other role access to the database!

-- Grant Privileges to the Share for the SYSADMIN Role?  
grant imported privileges
on database SNOWFLAKE_SAMPLE_DATA
to role SYSADMIN;

-- Use Select Statements to Look at Sample Data
--Check the range of values in the Market Segment Column
SELECT DISTINCT c_mktsegment
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER;

--Find out which Market Segments have the most customers
SELECT c_mktsegment, COUNT(*)
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER
GROUP BY c_mktsegment
ORDER BY COUNT(*);

-- PRO TIP: To run consecutive SELECT statements, without using your mouse, use CTRL+Enter or CMD+Enter. 

-- Join and Aggregate Shared Data
-- Nations Table
SELECT N_NATIONKEY, N_NAME, N_REGIONKEY
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.NATION;

-- Regions Table
SELECT R_REGIONKEY, R_NAME
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.REGION;

-- Join the Tables and Sort
SELECT R_NAME as Region, N_NAME as Nation
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.NATION 
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.REGION 
ON N_REGIONKEY = R_REGIONKEY
ORDER BY R_NAME, N_NAME ASC;

--Group and Count Rows Per Region
SELECT R_NAME as Region, count(N_NAME) as NUM_COUNTRIES
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.NATION 
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.REGION 
ON N_REGIONKEY = R_REGIONKEY
GROUP BY R_NAME;


-- Export Native and Shared Data
/*
The real value of consuming shared data is:
    - Someone else will maintain it over time and keep it fresh
    - Someone else will pay to store it
    - You will only pay to query it
*/

-- Set Your Default Role to SYSADMIN
alter user calebhorst set default_role = sysadmin;
alter user calebhorst set default_warehouse = compute_wh;
-- Check for Warehouses Accessible to SYSADMIN
use role accountadmin;
grant usage on warehouse compute_wh to role sysadmin;


show databases like 'UTIL_DB';
desc database util_db;



-- Can You Find the Function Using Code? 
-- where did you put the function?
show user functions in account;

-- did you put it here?
select * 
from util_db.information_schema.functions
where function_name = 'GRADER'
and function_catalog = 'UTIL_DB'
and function_owner = 'ACCOUNTADMIN';

-- Give the SYSADMIN Role Access to the Grader Function
grant usage 
on function UTIL_DB.PUBLIC.GRADER(VARCHAR, BOOLEAN, NUMBER, NUMBER, VARCHAR) 
to SYSADMIN;

-- Is DORA Working? Run This to Find Out!
select GRADER(step,(actual = expected), actual, expected, description) as graded_results from (
SELECT 'DORA_IS_WORKING' as step
 ,(select 223 ) as actual
 ,223 as expected
 ,'Dora is working!' as description
); 

-- Navigate to Your Cost Management Page
/*
The account shown above is a Trial Account set up for this workshop. At this point in the workshop, this learner has used 7/10's of 1 credit by running the COMPUTE_WH warehouse.  
$3.00 * 0.7 credits = $2.10 spent

The account shown in the image is on the AWS Cloud Platform in the US East 2 (Ohio) Region.  The question below is about the image you see above. We cannot ask a multiple-choice question about your own account usage because the answers will vary. 
*/