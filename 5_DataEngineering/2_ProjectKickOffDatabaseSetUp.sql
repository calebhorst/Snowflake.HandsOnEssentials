/*
Every Saturday morning, Kishore and Agnieszka play pick-up basketball. Kishore's best friend Tsai, plays in the games, too.  After their games, they go to their favorite smoothie shop. This week, they plan to brainstorm about their project.



On their way to the smoothie shop, Agnie uses her phone to send Kishore a log file she wants to discuss. Kishore downloads the file to a cloud folder.

You should download the file, too:  DNGW_Sample_from_Agnies_Game.json You can save it to your local machine. 



As they wait for their smoothies, Tsai asks if today's meeting is their project kick-off meeting. Kishore and Agnie are a little confused because their current jobs don't involve project work so they've never attended a project kick-off meeting, before.

After Tsai's explanation, they all agree that today's smoothie shop visit should be called their Project Kick-Off Meeting. 

🏆 Always Explore Your Source Files
Kishore is very curious and that helps him in his current job writing SQL reports. Curiosity will also be important if he someday achieves his goal of becoming a Data Engineer.

When Agnie sent him a log file, he immediately wanted to dig into it and see what it contained. He has a few favorite tools he uses to explore data files. You should already know of some tools, as well. We covered them in earlier workshops. 

Notepad++ is an excellent, free, text editor that allows you to see all kinds of structural characters (tabs, ¶ and more!). For Mac Users, BBEdit, Sublime Text, CotEditor and others are often used. 

curiosity

Use a Creative Role
Data Engineers will use a role like SYSADMIN for most of their tasks. SYSADMIN is a creative role and Data Engineers are creative creators. Throughout this workshop, you should use SYSADMIN for any task that doesn't require ACCOUNTADMIN. 

SYSADMIN should own any object you create. So databases, schemas, views, file formats, stages -- everything -- they should all be owned by the SYSADMIN role. 

Avoid Using All Powerful Roles to Create
Data Engineers in most companies don't even have the ACCOUNTADMIN role. You may use this role a time or two, but not often. When in doubt, SYSADMIN is the role to choose! 

Remember, you can set your default role to SYSADMIN, which is convenient for new worksheets and each time you login.

Use a command like this: 
ALTER USER <my user name> SET DEFAULT_ROLE = 'SYSADMIN';
*/

/*
🎯 Create the Project Infrastructure
Use SYSADMIN.
Create a database named AGS_GAME_AUDIENCE
Drop the PUBLIC schema.
Create a schema named RAW.
Double check everything. Did you name each item correctly? If not, use the ALTER statement to rename them.

Did you use SYSADMIN when creating things? If not, transfer the ownership of each object so it will be owned by the SYSADMIN role. 

🥋 Use a Code Template to Create a Table
Snowflake has some code templates available that can help you when creating objects. 
*/

use role sysadmin;
create database if not exists ags_game_audience;
drop schema if exists public;
create schema if not exists raw;

create or replace table ags_game_audience.raw.game_logs (
  raw_log variant
)
;

/*
🥋 Create an External Stage

NOTE: Notice one of the names has a dash and the other has an underscore. It's easy to get this mixed up. AWS bucket names cannot have underscores. Snowflake stage names cannot have dashes!!
*/
create stage if not exists ags_game_audience.raw.uni_kishore
url = 's3://uni-kishore'
;

-- 🥋 Test the Stage & Have a Look Around
-- Remember that a LIST command is a great way to make sure your stage is working and to get the names of files within the stage.  However, if you have Directory Table option turned on, you can just navigate the file structure by double-clicking to drill into folders. 

list @ags_game_audience.raw.uni_kishore;

/*
🎯 Create a File Format
Now you that you know how to find and use code templates, you can use a code template to create a file format. 

- Use SYSADMIN.
- Create a File Format in the AGS_GAME_AUDIENCE.RAW schema named FF_JSON_LOGS.
- Set the data file Type to JSON 
- Set the Strip Outer Array Property to TRUE   (strip_outer_array = true)
*/
use role sysadmin;
create file format ags_game_audience.raw.FF_JSON_LOGS
    type = 'JSON'
    strip_outer_array = true
    ;

/*
📓 Exploring the File Before Loading It
In the Data Lake Workshop (DLKW) we learned to query files while they were still sitting out in a file (not-loaded) in an external stage.

You also know from previous workshops that we can use a File Format to make the results of that query more readable. Try these methods to check your File Format before using it to load the data.

A statement like the one below can help you check that both your stage and your file format are working correctly. 
*/

select $1
from @ags_game_audience.raw.uni_kishore/kickoff
(file_format => ags_game_audience.raw.FF_JSON_LOGS)
;

/*
🥋 Load the File Into The Table
You've also had lots of experience writing COPY INTO statements during previous workshops. You are familiar with all the needed pieces (data file, table, stage, file format) and we've created those pieces in the previous few steps. Now you can easily write your COPY INTO statement and load the file into the table. 

Did you notice that we did not write out the file name in the FROM line? This is because there is only one file in the kickoff folder. A COPY INTO statement like the one shown above will load EVERY file in the folder if more than one file is there, and the file name is not specified. This will come in very handy later in the course. 

There are other ways to specify what files should be loaded and Snowflake gives you a lot of tools to further specify what will be loaded, but for now accept the general rule that by not naming the file, you are asking SNOWFLAKE to attempt to load ALL files the stage or stage/folder location. 
*/
copy into ags_game_audience.raw.game_logs
from @ags_game_audience.raw.uni_kishore/kickoff
file_format = (format_name = ags_game_audience.raw.FF_JSON_LOGS)
;

/*
🥋 Build a Select Statement that Separates Every Attribute into It's Own Column
The code shown here should get you started on your select statement, but you'll need to add to it.

Remember the JSON parsing PATHS and data type CASTING we learned in Badge 1?  Use those techniques to build a SELECT statement that separates every field in the RAW_LOG column into its own column of the SELECT results. The order of columns is not important.   For the column that contains data and time information, cast it to TIMESTAMP_NTZ. 

Include the original column RAW_LOG as the last column. We always like to be able to refer back to the original JSON so carrying this field forward is a good idea. 

When your SELECT is complete, you should have 5 columns.  Four of the column names should MATCH the four keys of the key/value pairs shown in red above. 
*/
select
  raw_log:agent::text as agent
  ,raw_log:user_event::text as user_event
  ,raw_log:user_login::text as user_login
  ,raw_log:datetime_iso8601::timestamp as datetime_iso8601
  ,*
from game_logs
;

/*
📓 Wrapping Selects in Views 
To save a select statement and make it easier to use, we simply take the select, and wrap it in a CREATE VIEW statement.

Like this: 

CREATE VIEW my_view as (select x,y,z);

You just finished creating a nice select that makes Agnie's game logs easy to view. You will be wrapping that select statement in a view. Follow the guidelines below. 
*/
CREATE VIEW raw.logs as
select
  raw_log:agent::text as agent
  ,raw_log:user_event::text as user_event
  ,raw_log:user_login::text as user_login
  ,raw_log:datetime_iso8601::timestamp as datetime_iso8601
  ,*
from game_logs
;

select *
from raw.logs
;

use util_db.public;
-- DO NOT EDIT THIS CODE
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from
(
 SELECT
 'DNGW01' as step
  ,(
      select count(*)  
      from ags_game_audience.raw.logs
      where is_timestamp_ntz(to_variant(datetime_iso8601))= TRUE 
   ) as actual
, 250 as expected
, 'Project DB and Log File Set Up Correctly' as description
); 

