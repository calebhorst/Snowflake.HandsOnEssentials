-- Create a New Database
create database if not exists demo_db;

-- Switch Your System Role to SYSADMIN
use role sysadmin;

-- Switch Your System Role Back to ACCOUNTADMIN
use role accountadmin;

-- Explore the Database You Created
select *
from information_schema.databases;

/*
Databases are used to group datasets (tables) together. A second-level organizational grouping, within a database, is called a schema. Every time you create a database, Snowflake will automatically create two schemas for you.

The INFORMATION_SCHEMA schema holds a collection of views.  The INFORMATION_SCHEMA schema cannot be deleted (dropped), renamed, or moved.

The PUBLIC schema is created empty and you can fill it with tables, views and other things over time. The PUBLIC schema can be dropped, renamed, or moved at any time.  
 */

 