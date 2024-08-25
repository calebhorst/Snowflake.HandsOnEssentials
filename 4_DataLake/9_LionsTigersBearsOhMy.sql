/*
📓  Materialized Views, External Tables,  and Iceberg Tables
Lions, and Tigers, and Bears, Oh My! -- Dorothy, Wizard of Oz.

But in our case, it's:

Materialized Views, and
External Tables, and 
Iceberg Tables! 
Oh My! What are all these things?

In short, all of these objects are attempts to make your less-normalized (possibly non-loaded) data look and perform like more-normalized (possibly loaded) data. 

📓  Materialized Views
A Materialized View is like a view that is frozen in place (more or less looks and acts like a table).

The big difference is that if some part of the underlying data changes,  Snowflake recognizes the need to refresh it, automatically.

People often choose to create a materialized view if they have a view with intensive logic that they query often but that does NOT change often.  We can't use a Materialized view on any of our trails data because you can't put a materialized view directly on top of staged data. 

📓  External Tables
An External Table is a table put over the top of non-loaded data (sounds like our recent views, right?).

An External Table points at a stage folder(yep, we know how to do that!) and includes a reference to a file format (or formatting attributes) much like what we've been doing with our views for most of this workshop! Seems very straightforward and something within reach-- given what we've already learned in this workshop!

But, if we look at docs.snowflake.com the syntax for External tables looks intimidating. Let's break it down into what we can easily understand and have experience with, and the parts that are little less straightforward. 

There are other parts that are somewhat new, but that don't seem complicated. In our views we define the PATH and CAST first and then assign a name by saying AS <column name>. For the external table we just flip the order. State the column name first, then AS, then the PATH and CAST column definition. 

Also, there's a property called AUTO_REFRESH -- which seems self-explanatory!

But External Tables seem like they have some weird, intense, unfamiliar things, too. Partitioning schemes and streaming message notification integrations are going to make more sense for Data Engineers (and the Data Engineering Hands-On Workshop!)

So, CAN/SHOULD we try to create an External Table to do the job of one of our existing views? Sure!

We'll start by including only the most essential lines, that way we can learn about External Tables iteratively. 
*/

-- 🥋 Let's TRY TO CREATE a Super-Simple, Stripped Down External Table
use role sysadmin;

use database mels_smoothie_challenge_db;
use schema trails;
create or replace external table T_CHERRY_CREEK_TRAIL(
	my_filename varchar(100) as (metadata$filename::varchar(100))
) 
location= @trails_parquet
auto_refresh = true
file_format = (type = parquet); -- Cannot use internal stage TRAILS_PARQUET as the location for an external table.

/*
📓 Why Do We Need External Storage for an External Table?
As you might suspect from the name, External tables were actually created with External Storage in mind. 

Mel and Zena are building rapid prototypes. That's their reason for using non-loaded data.

But most of the time organizations avoid loading data because:

They don't want to fully denormalize it yet, or
They can't move the data into Snowflake for security or governance reasons, or
They don't want multiple copies of data and the data has to be available to some other system, or
They're trying to avoid vendor lock in with Snowflake. 
So most of the time, when engineers choose not to load data into Snowflake, it's being stored outside of Snowflake and the tools you've been learning help them do just that.

Externally stored data is usually in Azure Blob storage, GCP Buckets or AWS S3 Buckets. 

In the Essentials Badge Workshops, we try not to make you sign up for Azure, GCP or AWS accounts so whenever we step outside of Snowflake, we often do that work for you, and have you follow steps that simulate parts of the process. 

In this case, we have set up an AWS S3 bucket and loaded the same Cherry Creek Trail Parquet file into it. That way, you can continue exploring External Tables, without setting up your own AWS account. 
*/

-- 🥋 Create an External Stage for an External Table
create stage if not exists mels_smoothie_challenge_db.trails.external_aws_dlkw
url = 's3://uni-dlkw'
;

/*
🥋 Let's TRY AGAIN to Create a Super-Simple, Stripped Down External Table
Change the length of the file name and change the name of the STAGE to your new External Stage, then, run the command again. 

After creating the table, run a SELECT * to make sure you get results back. 
*/
create or replace external table T_CHERRY_CREEK_TRAIL(
	my_filename varchar(100) as (metadata$filename::varchar(100))
) 
location= @external_aws_dlkw
auto_refresh = true
file_format = (type = parquet); -- Table T_CHERRY_CREEK_TRAIL successfully created.

select *
from T_CHERRY_CREEK_TRAIL
;

/*
📓 Remember those Materialized Views?
Remember a few pages ago when we told you:

We can't use a Materialized View on any of our trails data because you can't put a materialized view on top of staged data. 



Well, we left out an important detail. You CAN put a Materialized View over an External Table, even if that External Table is based on a Stage!!

In other words, you CAN put a Materialized View over staged data, as long as you put an External Table in between them, first!

With our newest view we are going to do a few things:

Remember the error in the Parquet file that flips Longitude and Latitude and fix the issue. 
Calculate the distance to Melanie's Cafe for EVERY ONE of the 3500 points along the trail. 
This is a great use of a materialized view with an external table. Since the calculation is somewhat intensive, but the location DOES NOT change. If we used a regular view, that view would be recalculating that distance over and over each time it was run. With a Materialized view, it will only change if the Cherry Creek Trail changes or Melanie's Cafe moves to a different building. 

🥋 Create a Materialized View Version of Our New External Table
Actually, make it a Secure Materialized View and name it SMV_CHERRY_CREEK_TRAIL.  We're going to use a copy of the original CHERRY_CREEK_TRAIL view as our starting point. 
*/
create secure materialized view MELS_SMOOTHIE_CHALLENGE_DB.TRAILS.SMV_CHERRY_CREEK_TRAIL(
	POINT_ID,
	TRAIL_NAME,
	LNG,
	LAT,
	COORD_PAIR,
    DISTANCE_TO_MELANIES
) as
select 
 value:sequence_1 as point_id,
 value:trail_name::varchar as trail_name,
 value:latitude::number(11,8) as lng,
 value:longitude::number(11,8) as lat,
 lng||' '||lat as coord_pair,
 locations.distance_to_mc(lng,lat) as distance_to_melanies
from t_cherry_creek_trail
;

use util_db.public;
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from
(
  SELECT
  'DLKW09' as step
  ,( select row_count
     from mels_smoothie_challenge_db.information_schema.tables
     where table_schema = 'TRAILS'
    and table_name = 'SMV_CHERRY_CREEK_TRAIL')   
   as actual
  ,3526 as expected
  ,'Secure Materialized View Created' as description
 ); 

/*
📓  Iceberg Tables
Iceberg is an open-source table type, which means a private company does not own the technology. Iceberg Table technology is not proprietary. 
Iceberg Tables are a layer of functionality you can lay on top of parquet files (just like the Cherry Creek Trails file we've been using) that will make files behave more like loaded data. In this way, it's like a file format, but also MUCH more. 
Iceberg Table data that can be editable via Snowflake! Read that again. Not just the tables are editable (like the table name), but the data they make available (like the data values in columns and rows). So, you will be able to create an Iceberg Table in Snowflake, on top of a set of parquet files that have NOT BEEN LOADED into Snowflake, and then run INSERT and UPDATE statements on the data using SQL 🤯. 
Iceberg Tables make Snowflake's Data Lake options incredibly powerful!!

THIS CHANGES EVERYTHING

People sometimes think of Snowflake as a solution for structured, normalized data (which they often call a Data Warehouse). For a while, people said Data Lakes were the only path forward. Lately, many people say the best solution is a Data Lakehouse (they're just mushing the two terms together and saying you need both).

Snowflake can be all of those things and Iceberg tables is an amazing addition. 

📓  Iceberg Tables
We followed this Docs Tutorial to configure some of the objects and permissions needed for you to get some hands on experience with Iceberg. 

Refer to the link above if you decide to set up your own Iceberg tables, in your own AWS (or other cloud) account.

FYI: On page 2 of the tutorial linked above, we DID NOT create a database and warehouse . You will be creating a database yourself, later, and using your own warehouse.

We have done the next set of steps (as outlined in the Docs Tutorial) so that you don't have to. 

On page 3 of the tutorial:
We DID create a bucket named uni-dlkw-iceberg. It is publicly viewable (like most the buckets we create for badge courses). 
We DID create a policy that grants access to our uni-dlkw-iceberg bucket. We named our policy dlkw-iceberg-learner-access-policy.
We DID create a role named dlkw_iceberg_role and for the External ID we used dlkw_iceberg_id. 
When it was time to create an external volume, we copied the code and edited it for you so that you can run it. Think of an external volume like an external hard drive of the 1990's. It's just a block of storage and in this case it is outside of Snowflake (but still in the cloud) instead of sitting next to your mouse where you can spill coffee on it and lose all the mp3's it took you weeks to download off of Napster. 
NOTE: NOW THAT WE HAVE DONE THE STEPS ABOVE ON YOUR BEHALF, YOU MUST DO THE STEPS BELOW. 

🥋 Create an External Volume
For the remainder of this workshop, you should do your work using the ACCOUNTADMIN Snowflake role. This will allow you to concentrate on the core tasks and not worry about granting privileges. 

*/
use role accountadmin;

CREATE OR REPLACE EXTERNAL VOLUME iceberg_external_volume
   STORAGE_LOCATIONS =
      (
         (
            NAME = 'iceberg-s3-us-west-2'
            STORAGE_PROVIDER = 'S3'
            STORAGE_BASE_URL = 's3://uni-dlkw-iceberg'
            STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::321463406630:role/dlkw_iceberg_role'
            STORAGE_AWS_EXTERNAL_ID = 'dlkw_iceberg_id'
         )
      );

DESC EXTERNAL VOLUME iceberg_external_volume;
/*
{"NAME":"iceberg-s3-us-west-2","STORAGE_PROVIDER":"S3","STORAGE_BASE_URL":"s3://uni-dlkw-iceberg","STORAGE_ALLOWED_LOCATIONS":["s3://uni-dlkw-iceberg/*"],"STORAGE_AWS_ROLE_ARN":"arn:aws:iam::321463406630:role/dlkw_iceberg_role"
,"STORAGE_AWS_IAM_USER_ARN":"arn:aws:iam::533267113044:user/wccp0000-s","STORAGE_AWS_EXTERNAL_ID":"dlkw_iceberg_id","ENCRYPTION_TYPE":"NONE","ENCRYPTION_KMS_KEY_ID":""} 
*/
-- 🥋 Create an Iceberg Database
create database my_iceberg_db
 catalog = 'SNOWFLAKE'
 external_volume = 'iceberg_external_volume';

-- 🥋 Create a Table 
-- This table will start with CCT for "Cherry Creek Trail" and have your Trial Account Locator appended to the end of the table name. This keeps each user from overwriting each other's tables. 

set table_name = 'CCT_'||current_account();

create iceberg table identifier($table_name) (
    point_id number(10,0)
    , trail_name string
    , coord_pair string
    , distance_to_melanies decimal(20,10)
    , user_name string
)
  BASE_LOCATION = $table_name
  AS SELECT top 100
    point_id
    , trail_name
    , coord_pair
    , distance_to_melanies
    , current_user()
  FROM MELS_SMOOTHIE_CHALLENGE_DB.TRAILS.SMV_CHERRY_CREEK_TRAIL;

  select * from identifier($table_name); 

/*
🪄 Troubleshooting Issues with Creating Your Iceberg Table
If your Snowflake Trial Account is not on AWS or not in the US-West Oregon Region, you cannot create an Iceberg table. We warned you about this with several lines of bold, red text in lesson 1. Accounts cannot be moved. Your only option is to start over in a new trial in the correct region. Others have told us this did not feel like a waste of time but instead was a pretty good review. 
When you enter your USER ARN into the YSA app, your user is IMMEDIATELY added to the policy, so coming to this page immediately to create your table is a great idea. If you wait too long, your user might queue out of the policy.  There is a limit of about 40 users that can share the policy at one time so the longer you wait, the more likely others will have entered their USER ARNs and bumped you out. 
If you miss your window  you may need to re-enter the Badge Management app and resave (to update the timestamp). This will bump you to the top of the list again and restart your window of opportunity. 
The app should let you know if you have a faulty entry but if you think there's an issue with the Badge Management App, please let us know below. 


Now that you've created your Iceberg table, try editing any value in any row. 

Something like this will work just as you'd expect:

update identifier($table_name)
set user_name = 'I am amazing!!'
where point_id = 1;
It worked right? And it acted just like any other Snowflake table.  

So you may be thinking, what is the big deal?  What's all the fuss about? These iceberg tables seem like any other Snowflake table, right?

Well, the fuss is something your CEO, CTO, and CFO care about more than you (as a boots-on-the-ground developer) are likely to care about, right now. 

Snowflake's new Iceberg features give your C-Suite confidence that they are not locked in with Snowflake -- if that's something they are worried about. They can store the data outside of Snowflake when that makes the most sense for a particular data set, without giving up all the things that make Snowflake easy to learn and easy to use. 

So now you can let you boss or potential future boss that you have experience with Iceberg tables and they will probably be very happy to hear it. */  

update identifier($table_name)
set user_name = 'I am amazing!!'
where point_id = 1;


set table_name = 'CCT_'||current_account();
select * from identifier($table_name); 

/*
Melanie and Igor have agreed to fund the project as long as the "kids" agree to some changes and responsibilities. 

They have a quick meeting and are able to outline some responsibilities:

Mel will continue to develop the mobile app, adding features like logins, check-ins, and leaderboards for competitors. 
Zena will convert her shopping app into a rewards redemption app where Mel's competitors can choose gear as rewards. Zena and Mel will work together to integrate the two app interfaces so they work smoothly, together. 
Camila will try to find a company that already helps athletes track their mileage. If she can work out a data sharing deal with Strava, Nike Training Club, Runtastic, or some other exercise tracking social network, Klaus thinks they might be able to query the tracking service using an API.  Camila will also reach out to local Bike Shops and try to work out promotional partnerships. 
Klaus will advise the team part time (he has a full time job at World Data Emporium, already) to help Mel, Zena, and Camila make the right choices for integrating the data they will need. He'll also help them decide when some of the data will need to be loaded into structured tables for long term maintenance and performance improvements. 
*/

/*
Problem
Match the data type with the symbol used in Snowflake Worksheets to represent the data type(s).

8 Icons used by Snowflake to represent data types in the worksheet
A with underscore: VARCAHR
0|1: BOOLEAN
#: NUMBER/FLOAT
(clock icon): DATE/TIMESTAMPT_TZ(9)
[]: VARIANT/ARRAY/OBJECT
(world icon): GEOGRAPHY
(triangle with points icon): GEOMETRY
(diamond with ? icon): VECTOR(INT,16)

Problem
Drag the files to classify them by structural type. Notice that there are two files labeled "TXT" but the graphics representing the data are different. This is because a TXT file can hold different data structures.

3 vertical columns labeled (l to r) Structured, Semi-structured, Unstructured
Structured: CSV, TSV, TXTSemi-Structured, dropzoneSemi-Structured
Semi-structured: Parquet, JSON, XML, TXT 2Unstructured, dropzoneUnstructured
Unstructured: PDF, MP3, EMAIL


L2: Which of these statements it the most durable and flexible definition of a Snowflake Stage Object?
It's a temporary location for storing data.
It's a cloud folder.
✔️ It's a named gateway that allows Snowflake users to easily connect to cloud folders and access the data stored in them.

L3: If we don't tell Snowflake anything about our file structure, what will it presume about the structure?
Select 3.

✔️ The file data is flat (not nested).
The file data is nested/hierarchical.
The data rows are separated by New-Record-# symbols.
✔️ The data rows are separated by Carriage Return/Line Feed symbols.
✔️ The data columns are separated using commas.
The data columns are separated using | or ^.


L3: What is the Snowflake Object that helps us communicate with Snowflake about the structure of our data?
SCHEMA
STAGE
✔️ FILE FORMAT
TASK

L3: Comma Separated files use Commas as the symbol for column separation. What is another name for "Column Separator"?
Row Parser
✔️ Field Delimiter
Record Delimiter
Row Separator

L3: In an earlier Workshop, we learned that FILE FORMATS are essential tools for loading data. What additional use for FILE FORMATS have we now discovered?
File formats can also be helpful when creating stages.
File formats can also be helpful in running warehouses.
✔️ File formats can also be helpful when querying staged files.

L4: What is it called when we put one function inside of another?
Collapsing
Truncating
Coalescing
✔️ Nesting

L4: When we talk about Data Lakes in Snowflake, what do we mean?
Data that flows easily and is always fresh because it doesn't stagnate.
Data that is loaded into internal Snowflake tables using a Snowflake object called a Stream.
✔️ Data that is left outside of Snowflake but can be accessed using Snowflake tools.
Data that cannot be accessed using a tool called a Stream.

L6: What GeoSpatial Data Formats have we used in this workshop so far?
✔️ Well Known Text (WKT)
Keyhole Markup Language (KML)
✔️ GeoJSON
Well Known Binary (WKB)

L7: What does the ST_ at the beginning of so many GeoSpatial Function names stand for?
STRING
Sterling (Silver)
✔️ Spatial Type
Stretch
correct

L7: What GeoSpatial Data Functions have we used in this workshop?
✔️ TO_GEOGRAPHY()
✔️ ST_LENGTH()
✔️ ST_XMIN()
✔️ ST_YMAX()
STDDEV

L8: Which of the options below could be called a FUNCTION SIGNATURE?
CREATE FUNCTION MY_COOL_FUNCTION
MY_COOL_FUNCTION()
✔️ MY_COOL_FUNCTION(x number, y text)
SELECT MY_COOL_FUNCTION(2,'Hello')

What are Materialized Views, External Tables and Iceberg Tables generally used for?
To load data into Snowflake quickly.
To unload data from Snowflake quickly.
✔️ To provide Snowflake access to data that has not been loaded.
To extract, transform, and load (ETL) data into Snowflake.

 */

USE UTIL_DB.PUBLIC;
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from
(
  SELECT
  'DLKW10' as step
  ,( select row_count
      from MY_ICEBERG_DB.INFORMATION_SCHEMA.TABLES
      where table_catalog = 'MY_ICEBERG_DB'
      and table_name like 'CCT_%'
      and table_type = 'BASE TABLE')   
   as actual
  ,100 as expected
  ,'Iceberg table created and populated!' as description
 ); 