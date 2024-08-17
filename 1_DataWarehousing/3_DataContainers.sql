-- LAB STEP-BY-STEP  (as shown above)
use role sysadmin;
create database if not exists garden_plants;
drop schema if exists public;
use database garden_plants;
create schema if not exists veggies;
create schema if not exists fruits;
create schema if not exists flowers;

-- Create a Worksheet & Run Some Code
select 'hello' as "Greeting";

-- Run the SHOW DATABASES Command
show databases;
show schemas;

-- Change the Database Context and Run the SHOW SCHEMAS Command Again
use database snowflake_sample_data;
show schemas;


-- All schemas from all databases are shown (based on current role).
SHOW SCHEMAS IN ACCOUNT;
