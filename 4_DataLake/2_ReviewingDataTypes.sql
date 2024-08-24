/*
📓  Reviewing Data Types
The most commonly used data types in the workshops so far have been VARCHAR and NUMBER (and possibly VARIANT). But there are many other data types in Snowflake. 
*/

--🥋 Try This Fake Table to View Data Type Symbols
use role sysadmin;

create or replace table util_db.public.my_data_types
(
  my_number number
, my_text varchar(10)
, my_bool boolean
, my_float float
, my_date date
, my_timestamp timestamp_tz
, my_variant variant
, my_array array
, my_object object
, my_geography geography
, my_geometry geometry
, my_vector vector(int,16)
);


/*
📓  Viewing the Data Types in a Table
When using Snowflake Worksheets, if you click on a table name in the left side menu, you will see a subpanel at the bottom, and are able to view the columns (including data types and icons representing the data types). 

📓  Zena's Athleisure Product Catalog!
Zena wants to convince Igor and Melanie to sell athletic and athleisure clothing as an expansion business for the smoothie shop.

Her plan is to try to create a sample clothing catalog to show them. She finds some generic sweat suit pictures online, and saves them to her laptop. But, are images a form of data? Or not? And how will she store and manage the image "data"?

📓  Reviewing Data File Structures
Though any data file is made up of data, and those data points can be different types, the structure of the data and how it is arranged in the file is different than data types (like VARCHAR, BOOLEAN, VARIANT, etc). 

Structured Data:

Rows and columns
Commas, tabs or other characters separating the columns
No nesting of data
Semi-Structured Data: 

Can be nested
Uses angle brackets (< >) and curly brackets ({ }) to separate values
Arranged as key/value pairs
Unstructured Data:

No patterns for separating one value from another
Examples include documents, audio files, video files and more
Snowflake added tools and support for unstructured data in August of 2021
*/

/*
🎯 Create a Database for Zena's Athleisure Idea
You will create an External Stage in Snowflake that points to the "clothing" folder in Klaus' bucket, but before you do that:

Create a database called ZENAS_ATHLEISURE_DB and make sure the SYSADMIN role owns it. 
Drop the PUBLIC schema
Create a schema called PRODUCTS (make sure it is also owned by SYSADMIN). 
*/

use role sysadmin;
create database if not exists ZENAS_ATHLEISURE_DB;
drop schema if exists public;
create schema if not exists products;

-- 🥋 Create an Internal Stage and Load the Sweatsuit Files Into It
-- Download and unzip this file: sweatsuits.zip
show stages in account;

create stage if not exists ZENAS_ATHLEISURE_DB.products.sweatsuits
encryption = (TYPE = 'SNOWFLAKE_SSE')
comment = 'a place to hold files before loading them';

/*
🎯 Create Another Internal Stage
Again, in the PRODUCTS schema of Zena's database, and owned by SYSADMIN.

This time create an internal stage and call it PRODUCT_METADATA. 
THIS TIME USE CLIENT-SIDE ENCRYPTION.

Load the files from this zip into the new stage:  metadata.zip

At the end of this lab, you should have created one database, deleted one schema and created another (for a total of 2 schemas), and created 2 stages. 
*/

create stage if not exists ZENAS_ATHLEISURE_DB.products.product_metadata
encryption = (TYPE = 'SNOWFLAKE_FULL')
comment = 'a place to hold files before loading them';

/*
📓  Revisiting the Warehouse Staging Metaphor, Again!!
Remember back in Badge 1: Data Warehousing Workshop when Tsai first learned about Stages? We created an External Stage pointed at an AWS S3 bucket and used it to load data into our tables using COPY INTO statements. 

When we first learned about stages and the staging of files, we said that Snowflake Internal tables (regular tables) were like the shelving in a real-world warehouse. With tables being a place where we would very deliberately place our data for long-term storage. We also claimed that the yellow areas on the floor of a a warehouse were like stages in Snowflake. 

By the time we finished Badge 3: Data Application Builders Workshop, Mel understood the difference between External and Internal Stages, how to set them up and use them. He also understood that when we talk about "Stages" there are actually 3 parts. The cloud folder is the stage's storage location, the files within those locations are "staged data", and the objects we create in Snowflake are not locations, instead they are connections to cloud folders - which metaphorically can also be called "windows", or shown as loading bay doors on diagrams. 

In this workshop, we're going to learn that Snowflake Stage Objects are even less "stage-y" than we've already discovered.

It's not that we were wrong in the past. It's just that we are more sophisticated now, and need a more nuanced metaphor!

As it turns out, a Snowflake Stage Object can be used to connect to and access files and data you never intend to load!!! 

Zena can create a stage that points to an external or internal bucket. Then, instead of pulling data through the stage into a table, she can reach through the stage to access and analyze the data where it is already sitting.

She does not have to load data, she can leave it where it is already stored, but still access it AND if she uses a File Format, she can make it appear almost as if it is actually loaded! (weird, but true!) 

REDEFINING THE WORD "STAGE" FOR SNOWFLAKE ADVANCED USE
We already know that in the wider world of Data Warehousing, we can use the word "stage" to mean "a temporary storage location", and we can also use "stage" to mean a cloud folder where data is stored -- but now, more than ever, we should open our mind to the idea that a defined Snowflake Stage Object is most accurately thought of as a named gateway into a cloud folder where, presumably, data files are stored either short OR long term. 
*/

use util_db.public;
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from
(
 SELECT
 'DLKW01' as step
  ,( select count(*)  
      from ZENAS_ATHLEISURE_DB.INFORMATION_SCHEMA.STAGES 
      where stage_schema = 'PRODUCTS'
      and 
      (stage_type = 'Internal Named' 
      and stage_name = ('PRODUCT_METADATA'))
      or stage_name = ('SWEATSUITS')
   ) as actual
, 2 as expected
, 'Zena stages look good' as description
); 