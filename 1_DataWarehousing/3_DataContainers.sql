-- LAB STEP-BY-STEP  (as shown above)
USE ROLE sysadmin;
CREATE DATABASE IF NOT EXISTS garden_plants;
DROP SCHEMA IF EXISTS public;
USE DATABASE garden_plants;
CREATE SCHEMA IF NOT EXISTS veggies;
CREATE SCHEMA IF NOT EXISTS fruits;
CREATE SCHEMA IF NOT EXISTS flowers;

-- Create a Worksheet & Run Some Code
SELECT 'hello' AS "Greeting";

-- Run the SHOW DATABASES Command
SHOW DATABASES;
SHOW SCHEMAS;

-- Change the Database Context and Run the SHOW SCHEMAS Command Again
USE DATABASE snowflake_sample_data;
SHOW SCHEMAS;


-- All schemas from all databases are shown (based on current role).
SHOW SCHEMAS IN ACCOUNT;
