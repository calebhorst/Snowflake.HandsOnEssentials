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
USE ROLE accountadmin;
DROP DATABASE snowflake_sample_data;

-- View Changes to the Private Sharing Page 
-- If the blue download button doesn't appear on the SAMPLE_DATA listing, just refresh the page (top right corner under the [Share] button. If that doesn't work, use the browser refresh button. 

-- Adding the Sample Data Back (I named it as SFK_SAMPLE_DATA)
-- Web UI
-- Once the database appears in your account again, you may need to wait 10-15 seconds for the data to show up. Feel free to refresh as needed. 

-- Create a SQL Worksheet & Name It "CMCW Lesson 2"
-- Setting the Sample Share Name Back to the Original Name
ALTER DATABASE sfk_sample_data
RENAME TO snowflake_sample_data;

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
GRANT IMPORTED PRIVILEGES
ON DATABASE snowflake_sample_data
TO ROLE sysadmin;

-- Use Select Statements to Look at Sample Data
--Check the range of values in the Market Segment Column
SELECT DISTINCT c_mktsegment
FROM snowflake_sample_data.tpch_sf1.customer;

--Find out which Market Segments have the most customers
SELECT
  c_mktsegment,
  COUNT(*)
FROM snowflake_sample_data.tpch_sf1.customer
GROUP BY c_mktsegment
ORDER BY COUNT(*);

-- PRO TIP: To run consecutive SELECT statements, without using your mouse, use CTRL+Enter or CMD+Enter. 

-- Join and Aggregate Shared Data
-- Nations Table
SELECT
  n_nationkey,
  n_name,
  n_regionkey
FROM snowflake_sample_data.tpch_sf1.nation;

-- Regions Table
SELECT
  r_regionkey,
  r_name
FROM snowflake_sample_data.tpch_sf1.region;

-- Join the Tables and Sort
SELECT
  r_name AS region,
  n_name AS nation
FROM snowflake_sample_data.tpch_sf1.nation 
INNER JOIN snowflake_sample_data.tpch_sf1.region 
  ON n_regionkey = r_regionkey
ORDER BY r_name, n_name ASC;

--Group and Count Rows Per Region
SELECT
  r_name AS region,
  COUNT(n_name) AS num_countries
FROM snowflake_sample_data.tpch_sf1.nation 
INNER JOIN snowflake_sample_data.tpch_sf1.region 
  ON n_regionkey = r_regionkey
GROUP BY r_name;


-- Export Native and Shared Data
/*
The real value of consuming shared data is:
    - Someone else will maintain it over time and keep it fresh
    - Someone else will pay to store it
    - You will only pay to query it
*/

-- Set Your Default Role to SYSADMIN
ALTER USER calebhorst SET default_role = sysadmin;
ALTER USER calebhorst SET default_warehouse = compute_wh;
-- Check for Warehouses Accessible to SYSADMIN
USE ROLE accountadmin;
GRANT USAGE ON WAREHOUSE compute_wh TO ROLE sysadmin;


SHOW DATABASES LIKE 'UTIL_DB';
DESC DATABASE util_db;



-- Can You Find the Function Using Code? 
-- where did you put the function?
SHOW USER FUNCTIONS IN ACCOUNT;

-- did you put it here?
SELECT * 
FROM util_db.information_schema.functions
WHERE function_name = 'GRADER'
  AND function_catalog = 'UTIL_DB'
  AND function_owner = 'ACCOUNTADMIN';

-- Give the SYSADMIN Role Access to the Grader Function
GRANT USAGE 
ON FUNCTION UTIL_DB.PUBLIC.GRADER(VARCHAR, BOOLEAN, NUMBER, NUMBER, VARCHAR) 
TO sysadmin;

-- Is DORA Working? Run This to Find Out!
SELECT GRADER(step,(actual = expected), actual, expected, description) AS graded_results FROM (
  SELECT
    'DORA_IS_WORKING' AS step,
    (SELECT 223 ) AS actual,
    223 AS expected,
    'Dora is working!' AS description
); 

-- Navigate to Your Cost Management Page
/*
The account shown above is a Trial Account set up for this workshop. At this point in the workshop, this learner has used 7/10's of 1 credit by running the COMPUTE_WH warehouse.  
$3.00 * 0.7 credits = $2.10 spent

The account shown in the image is on the AWS Cloud Platform in the US East 2 (Ohio) Region.  The question below is about the image you see above. We cannot ask a multiple-choice question about your own account usage because the answers will vary. 
*/