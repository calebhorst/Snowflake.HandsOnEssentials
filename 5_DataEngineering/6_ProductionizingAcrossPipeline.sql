/*
📓 We Have A Data Pipeline!
By "data pipeline" we mean:

A series of steps...
that move data from one place to another...
in a repeated way.

pipeline

Does our current method fit this definition?

It is a series of steps.
It moves data.
It is repeatable (even if it is manual). 

But our pipeline could also be improved. For example:

The step (#1) where Agnie loads the data into the S3 bucket could be automated. 
The step (#2) where Kishore runs the COPY INTO to move the files from the stage, into the RAW_LOGS table, could also be automated. 
We just spent a lot of time making Step 4 work REALLY WELL!! We're not planning to rewrite Step 4 because it works great! We're also not abandoning Step 4. Instead, we're shifting our focus to the preceding steps so we can make them as sophisticated as we made Step 4!

📓 Automating Step 1: Agnie's Files Moved Into the Bucket
Wanna hear some great news?  We already automated step 1 for you!!

pipeline

As with other Hands On Essentials Workshops, we did NOT want to require you to set up an AWS console account, set up a bucket, and set up a process to load files into it. As a Data Engineer you might be responsible for creating a process like this, or you might not.

To keep things focused (and save you some money), we created an automated process to simulate a production environment where files are being delivered to your bucket every 5 minutes. 

If you set up a stage for this bucket, and run a LIST command several times, you'll be able to see that a new file is being added to the bucket every 5 minutes. 

🎯 Create A New Stage
Remember, everything you create should be owned by SYSADMIN. 

1) Create a new stage called UNI_KISHORE_PIPELINE that points to s3://uni-kishore-pipeline. Put this stage in the RAW schema. 

2) Check the current time in UTC. If it is currently almost midnight UTC, expect lots of files. If it is just after midnight UTC, expect very few files. 

3) Enable the Directory and view the files in the bucket. Depending on the time of day you run this, the number of files you see will vary.  You might see 2, you might see hundreds. 
*/
use role sysadmin;
create stage if not exists AGS_GAME_AUDIENCE.RAW.UNI_KISHORE_PIPELINE
url = 's3://uni-kishore-pipeline'
;

list @AGS_GAME_AUDIENCE.RAW.UNI_KISHORE_PIPELINE;

/*
📓 Why Do the Files Disappear at Midnight UTC?
We write the same set of files every 24 hours and we needed a way to keep the bucket from getting too full.

So, every night at midnight UTC, we remove all the files and the process starts over. The first file our process writes will be named logs_1_10_0_0_0.json and it will have 10 log records in it. The second file will be called logs_11_20_0_0_0.json. 

Plan your labs with an understanding of this necessary weirdness. In the real world, the same set of files isn't written and deleted every 24 hours, but that's how we set it up for this workshop.
*/

/*
📓 Another Method (Very Cool) for Getting Template Code


The code shown above being copied is just an example. It is not the code you should be using for the next challenge lab. 

🎯 Create A New Raw Table!
Remember, everything you create should be owned by SYSADMIN. 

1) Create a table called PL_GAME_LOGS (put it in the RAW schema).  It should have the same structure as the GAME_LOGS table. Same column(s) and column data type(s). 
*/
use AGS_GAME_AUDIENCE.RAW;

desc table GAME_LOGS;

create table if not exists AGS_GAME_AUDIENCE.RAW.PL_GAME_LOGS (
    raw_log variant
)
;

/*
📓 You Are In the Process of Engineering a Pipeline
Now that we have a new stage to pull files from, and a target table for those files, we need a new COPY INTO to do the extract and load. We can re-use our existing file format. 

Use your previous COPY INTO (from Lesson 3) as a template for a new COPY INTO. 

🎯 Create Your New COPY INTO
Remember, everything you create should be owned by SYSADMIN. 

1) Write a COPY INTO statement that will load NOT just a specific named file into your table, but ANY file that lands in that folder. 

2) Test your COPY INTO statement and when you see the results, make a note of how many files were loaded. 

3) Look at your PL_GAME_LOGS table. How many rows does it have? Each file you load should have 10 records. Does the number of records seem correct?

4) Run your COPY INTO again. Each time you run it,  if a new file has been added, it will be loaded, if no new files are present, nothing will be loaded. 

IMPORTANT NOTE:  In line 2 of your COPY INTO command DO NOT include a folder or filename. Just put either: 

FROM @uni_kishore_pipeline , or
FROM @ags_game_audience.raw.uni_kishore_pipeline
and the command will pick up every available file and try to load it! You should NOT specify a file name. 
*/
copy into ags_game_audience.raw.PL_GAME_LOGS
FROM @ags_game_audience.raw.uni_kishore_pipeline
file_format = (format_name = ags_game_audience.raw.FF_JSON_LOGS)
;

/*
 📓 Idempotent COPY INTO
So, did you notice that the COPY INTO is smart enough to know which files it already loaded and it doesn't load the same file, twice?

Snowflake is designed like this to help you. Without any special effort on your part, you have a process that doesn't double-load files.  In other words, it automatically helps you keep your processes IDEMPOTENT.

But, what if, for some crazy reason, you wanted to double-load your files? 

You could add a FORCE=TRUE; as the last line of your COPY INTO statement and then you would double the number of rows in your table. 

Then, what if you wanted to start over and load just one copy of each file?

You could TRUNCATE TABLE PL_GAME_LOGS; , set FORCE=FALSE and run your COPY INTO again. 

 

The COPY INTO is very smart, which makes it useful and efficient!! We aren't going to use the FORCE command in this workshop. We aren't going to truncate and reload to prove the stage and COPY INTO are colluding in your favor (they really do!), but we wanted you to know they are available to you for special situations. 

🎯 Create a Step 2 Task to Run the COPY INTO
Remember, everything you create should be owned by SYSADMIN. 

Create a Task that runs every 10 minutes. Name your task GET_NEW_FILES (put it in the RAW schema)
Copy and paste your COPY INTO into the body of your GET_NEW_FILES task. 
Run the EXECUTE TASK command a few times. New files are being added to the stage every 5 minutes, so keep that in mind as you test.  
Check to confirm that your task executed successfully and that the data from the files is being loaded as you expect. 
*/

create or replace task raw.GET_NEW_FILES
warehouse=COMPUTE_WH
schedule = '1 minutes'
as
copy into ags_game_audience.raw.PL_GAME_LOGS
FROM @ags_game_audience.raw.uni_kishore_pipeline
file_format = (format_name = ags_game_audience.raw.FF_JSON_LOGS)
;


EXECUTE TASK raw.GET_NEW_FILES
;

/*
 📓  Step 3: The JSON-Parsing View
Remember how we load the logs into a very simple table with just one column so that we can load just about anything and parse it apart later? 

If yes, then you'll also remember that we called our JSON-Parsing view "LOGS" and it did the job of splitting one big JSON blob into different columns. 

So now that we have a new raw table, we need a new JSON-Parsing view for that table, too. 

🎯 Create a New JSON-Parsing View
Remember, everything you create should be owned by SYSADMIN. 

1) Using your LOGS view as a template, create a new view called PL_LOGS. The new view should pull from the new table.

2) Check the new view to make sure all your rows appear in your new view as you expect them to. 
*/
select *
from ags_game_audience.raw.PL_GAME_LOGS
;

CREATE or replace VIEW raw.PL_LOGS as
select
  raw_log:ip_address::text as ip_address
  ,raw_log:user_event::text as user_event
  ,raw_log:user_login::text as user_login
  ,raw_log:datetime_iso8601::timestamp_ntz as datetime_iso8601
  ,*
from ags_game_audience.raw.PL_GAME_LOGS
;

select * 
from raw.PL_LOGS
;

/*
🎯 Modify the Step 4 MERGE Task !
Files from a different stage are being loaded into a different raw table and those rows are being parsed by a different JSON-Parsing view.  
The one thing we are not changing is our DESTINATION table. 
That table is still going to be LOGS_ENHANCED and the task that loads that table is still going to be your Merge Task, LOAD_LOGS_ENHANCED.  

The source stage is now UNI_KISHORE_PIPELINE instead of UNI_KISHORE.
The raw table being loaded is now PL_GAME_LOGS instead of GAME_LOGS. 
The original JSON-parsing view of LOGS has been replaced by PL_LOGS. 
The destination table has not changed. It should still be LOGS_ENHANCED.
Does any of the code need to be changed to make your merge use these new sources?  If so, change your merge code! 

When you've made the changes, manually run your MERGE task and make sure it works to INSERT all those new rows into your LOGS_ENHANCED table. 
This is the only object that does not change. Our destination table remains the same, while all the source objects leading up to it have changed. 
*/

create or replace task ags_game_audience.raw.LOAD_LOGS_ENHANCED
warehouse='COMPUTE_WH'
schedule='5 minute'
as
MERGE INTO ENHANCED.LOGS_ENHANCED e
USING (
    SELECT logs.ip_address 
    , logs.user_login as GAMER_NAME
    , logs.user_event as GAME_EVENT_NAME
    , logs.datetime_iso8601 as GAME_EVENT_UTC
    , city
    , region
    , country
    , timezone as GAMER_LTZ_NAME
    , CONVERT_TIMEZONE( 'UTC',timezone,logs.datetime_iso8601) as game_event_ltz
    , DAYNAME(game_event_ltz) as DOW_NAME
    , TOD_NAME
    from ags_game_audience.raw.PL_LOGS logs
    JOIN ipinfo_geoloc.demo.location loc ON ipinfo_geoloc.public.TO_JOIN_KEY(logs.ip_address) = loc.join_key
      AND ipinfo_geoloc.public.TO_INT(logs.ip_address) BETWEEN start_ip_int AND end_ip_int
    JOIN ags_game_audience.raw.TIME_OF_DAY_LU tod ON HOUR(game_event_ltz) = tod.hour
) r
ON r.GAMER_NAME = e.GAMER_NAME
and r.GAME_EVENT_UTC = e.game_event_utc
and r.GAME_EVENT_NAME = e.game_event_name
WHEN NOT MATCHED THEN
insert (
    ip_address
    ,gamer_name
    ,game_event_name
    ,game_event_utc
    ,city
    ,region
    ,country
    ,gamer_ltz_name
    ,game_event_ltz
    ,dow_name
    ,tod_name
)
values (
    ip_address
    ,gamer_name
    ,game_event_name
    ,game_event_utc
    ,city
    ,region
    ,country
    ,gamer_ltz_name
    ,game_event_ltz
    ,dow_name
    ,tod_name
)
;

/*
 📓  Allowing Our Task to Run Itself
For Step 1 of our pipeline we have files being loaded into the external stage every 5 minutes. This is totally automated and your Snowflake Account is not paying for the compute time. This step is developed, managed, and paid for by Snowflake Education Services.  

For Step 2, we have just defined a task that would run every 5 minutes, but we have never allowed it to run. Instead, we keep using the EXECUTE TASK command. This one is "paid for" by your trial account credits and therefore, can be expensive. If you are not careful you might implement it in a way you might regret. (e.g. Use a 4XL warehouse on a task set to run every minute and your trial will expire really quickly!) 

Before releasing a TASK to run itself according to the schedule you set up, you should have some safeguards in place. 

On the next page, you'll set up a Resource Monitor, which will help you monitor and control the costs that come from pipelines. 
*/

/*
📓 Forgotten Tasks Can Eat Up Credits, Fast!
We created a task that we designed to run every 5 minutes. We didn't turn the task on, but once we do, it will start to use up our free trial credits! If we forget to turn off our task before going home for the day, we might come back to a trial account with no more credits! That's not fun. 

In order to relax while doing this course and not worry too much about leaving a task running, we're going to set up a RESOURCE MONITOR with a daily limit of 1 Credit hour. Our COMPUTE_WH (because it is sized eXtra Small) only uses 1 credit per hour so we should be able to get quite a bit done with a single credit each day. 

The RESOURCE MONITOR we create will shut down our tasks each day so that we don't waste credits. We may find it a little annoying from time to time, but it's better than having to start the workshop over, or enter a credit card, right? 

🎯 Create a Resource Monitor to Shut Things Down After an Hour of Use
We learned how to create Resource Monitors in Badge 1. We revisited Resource Monitors in Badge 2.  We talk about them all the time. Every DE should be able to create them and modify them!

We'll set up a daily resource monitor that will limit our use to one credit hour per day. If we need more, we can always change the quota. This might be a little annoying at times, but at least we won't have run-away costs. 
*/

-- Set Up A Resource Monitor
use role accountadmin;
create resource monitor if not exists daily_shut_down
with credit_quota = 1
frequency = daily
start_timestamp = immediately
triggers
    on 50 percent do notify
    on 75 percent do suspend
    on 98 percent do suspend_immediate
;

/*
🎯 Truncate The Target Table
Before we begin testing our new pipeline, TRUNCATE the target table ENHANCED.LOGS_ENHANCED so that we don't have the rows from our previous pipeline. Starting with zero rows gives us an easier way to check that our new processes work the way we intend. 
*/
use role sysadmin;

truncate table ENHANCED.LOGS_ENHANCED;

/*
📓 The Current State of Things
Our process is looking good. We have:

Step 1 TASK (invisible to you, but running every 5 minutes)
Step 2 TASK that will load the new files into the raw table every 5 minutes (as soon as we turn it on).
Step 3 VIEW that is kind of boring but it does some light transformation (JSON-parsing) work for us.  
Step 4 TASK  that will load the new rows into the enhanced table every 5 minutes (as soon as we turn it on).


So let's turn on the TASKS!! 

🥋 Turn on Your Tasks!
You can suspend and resume tasks using the GUI. 

You can also resume and suspend them using worksheet code. 
*/

--Turning on a task is done with a RESUME command
alter task AGS_GAME_AUDIENCE.RAW.GET_NEW_FILES resume;
alter task AGS_GAME_AUDIENCE.RAW.LOAD_LOGS_ENHANCED resume;

--Turning OFF a task is done with a SUSPEND command
alter task AGS_GAME_AUDIENCE.RAW.GET_NEW_FILES suspend;
alter task AGS_GAME_AUDIENCE.RAW.LOAD_LOGS_ENHANCED suspend;

/*
❕You Have Tasks Running!
You have tasks running right now. You also have a Resource Monitor that is going to put a stop to EVERYTHING after an hour of usage. 

Remember to always shut off your tasks when you quit your learning for the day. A Resource Monitor can protect your free credits if you forget to shut them off but why not just shut them off and save credits?  

You may have the opposite problem though! You may see a message saying your RESOURCE MONITOR has shut everything down because you exceeded your quota for today. If this happens, and you want to keep working, simply go back into your resource monitor and change the daily credit quota to 2 or 3 credits instead of 1. 

The resource monitor is designed to protect you but it is fully in your control. Edit it as needed to get your work done!
*/

/*
🥋 Let's Check Our Tasks
Navigate to the LOAD_LOGS_ENHANCED Task's page.

Note whether your TASK is owned by SYSADMIN, and whether it is running. If it is SCHEDULED, note the time it will next run.

Refresh the page after it has run again. Check to see if the TASK succeeded.

NOTE: If the task is not owned by SYSADMIN, you will have to SUSPEND it, change the ownership and then RESUME it. If the task is not running, run the ALTER command that ends in RESUME.

🎯 Check on the GET_NEW_FILES Task
Use the same methods to check on your other scheduled task. Make sure it is running and succeeding!
*/
show tasks;

use role accountadmin;
SELECT *
FROM snowflake.account_usage.task_history
ORDER BY completed_time DESC
LIMIT 100;

/*
🏆 Keeping Tallies in Mind
A good Data Engineer will constantly be thinking about how many rows they expect so that if something weird happens, they will recognize it sooner. 

STEP 1: Check the number of files in the stage, and multiply by 10. This is how many rows you should be expecting. 

STEP 2: The GET_NEW_FILES task grabs files from the UNI_KISHORE_PIPELINE stage and loads them into PL_GAME_LOGS. How many rows are in PL_GAME_LOGS? 

STEP 3: The PL_LOGS view normalizes PL_GAME_LOGS without moving the data. Even though there are some filters in the view, we don't expect to lose any rows. How many rows are in PL_LOGS?

STEP 4: The LOAD_LOGS_ENHANCED task uses the PL_LOGS view and 3 tables to enhance the data. We don't expect to lose any rows. How many rows are in LOGS_ENHANCED?

NOTE: If you lose records in Step 4, it could be because the time zone lookup against IPINFO_GEOLOC failed. These records losses are considered acceptable in this phase of the project.
*/

-- 🥋 Checking Tallies Along the Way
--Step 1 - how many files in the bucket?
list @AGS_GAME_AUDIENCE.RAW.UNI_KISHORE_PIPELINE;

--Step 2 - number of rows in raw table (should be file count x 10)
select count(*) from AGS_GAME_AUDIENCE.RAW.PL_GAME_LOGS;

--Step 3 - number of rows in raw view (should be file count x 10)
select count(*) from AGS_GAME_AUDIENCE.RAW.PL_LOGS;

--Step 4 - number of rows in enhanced table (should be file count x 10 but fewer rows is okay because not all IP addresses are available from the IPInfo share)
select count(*) from AGS_GAME_AUDIENCE.ENHANCED.LOGS_ENHANCED;


execute task AGS_GAME_AUDIENCE.RAW.GET_NEW_FILES;
execute task AGS_GAME_AUDIENCE.RAW.LOAD_LOGS_ENHANCED;

/*
📓 A Few Task Improvements
As you were tracing your results through all the locations, did it occur to you that the timing could mess up your tallies? What if a file had just been added to the bucket, but had not been picked up by the GET_NEW_FILE task? What if some rows had been processed by the GET_NEW_FILES task but had not yet been processed by the LOAD_LOGS_ENHANCED task? 

TASK DEPENDENCIES
One way we can improve this is through task dependencies. You can't control the Step 1 task -- in fact, you don't even know the name of it. But the Step 2 Task and the Step 4 Task are yours and you have full control over them. 

What if we ran GET_NEW_FILES every 5 minutes and then ran LOAD_LOGS_ENHANCED based on Snowflake telling us that GET_NEW_FILES just finished? That would remove some of the uncertainty. 

We'll make those changes in a moment - but before we do, let's talk about one other change. 

SERVERLESS COMPUTE
The WAREHOUSE we are using to run the tasks has to spin up each time we run the task. Then, if it's designed to auto-suspend in 5 minutes, it won't EVER suspend, because the task will run again before it has time to shut down. This can cost a lot of credits.

Snowflake has a different option called "SERVERLESS". It means you don't have to spin up a warehouse, instead you can use a thread or two of another compute resource that is already running. Serverless compute is much more efficient for these very small tasks that don't do very much, but do what they do quite often.  

To use the SERVERLESS task mode, we'll need to grant that privilege to SYSADMIN. 
*/

-- 🥋 Grant Serverless Task Management to SYSADMIN
use role accountadmin;
grant EXECUTE MANAGED TASK on account to SYSADMIN;

--switch back to sysadmin
use role sysadmin;

-- 🥋 Replace the WAREHOUSE Property in Your Tasks
/*
USER_TASK_MANAGED_INITIAL_WAREHOUSE_SIZE = 'XSMALL'
-- NOTE: This line REPLACES the WAREHOUSE line in the task. Do not use it in addition to a warehouse line. Replace the warehouse line with the line above

-- 🥋 Replace or Update the SCHEDULE Property
Use one of these lines in each task. Make sure you are using the SYSADMIN role when you replace these task definitions.  

--Change the SCHEDULE for GET_NEW_FILES so it runs more often
schedule='5 Minutes'

--Remove the SCHEDULE property and have LOAD_LOGS_ENHANCED run  
--each time GET_NEW_FILES completes
after AGS_GAME_AUDIENCE.RAW.GET_NEW_FILES
*/
alter task AGS_GAME_AUDIENCE.RAW.GET_NEW_FILES suspend;
create or replace task ags_game_audience.raw.LOAD_LOGS_ENHANCED
USER_TASK_MANAGED_INITIAL_WAREHOUSE_SIZE = 'XSMALL'
after AGS_GAME_AUDIENCE.RAW.GET_NEW_FILES
as
MERGE INTO ENHANCED.LOGS_ENHANCED e
USING (
    SELECT logs.ip_address 
    , logs.user_login as GAMER_NAME
    , logs.user_event as GAME_EVENT_NAME
    , logs.datetime_iso8601 as GAME_EVENT_UTC
    , city
    , region
    , country
    , timezone as GAMER_LTZ_NAME
    , CONVERT_TIMEZONE( 'UTC',timezone,logs.datetime_iso8601) as game_event_ltz
    , DAYNAME(game_event_ltz) as DOW_NAME
    , TOD_NAME
    from ags_game_audience.raw.PL_LOGS logs
    JOIN ipinfo_geoloc.demo.location loc ON ipinfo_geoloc.public.TO_JOIN_KEY(logs.ip_address) = loc.join_key
      AND ipinfo_geoloc.public.TO_INT(logs.ip_address) BETWEEN start_ip_int AND end_ip_int
    JOIN ags_game_audience.raw.TIME_OF_DAY_LU tod ON HOUR(game_event_ltz) = tod.hour
) r
ON r.GAMER_NAME = e.GAMER_NAME
and r.GAME_EVENT_UTC = e.game_event_utc
and r.GAME_EVENT_NAME = e.game_event_name
WHEN NOT MATCHED THEN
insert (
    ip_address
    ,gamer_name
    ,game_event_name
    ,game_event_utc
    ,city
    ,region
    ,country
    ,gamer_ltz_name
    ,game_event_ltz
    ,dow_name
    ,tod_name
)
values (
    ip_address
    ,gamer_name
    ,game_event_name
    ,game_event_utc
    ,city
    ,region
    ,country
    ,gamer_ltz_name
    ,game_event_ltz
    ,dow_name
    ,tod_name
)
;

/*
🎯 Resume the Tasks
Remember that each time you edit the task, you have to RESUME the task. You can do this using the GUI or with an ALTER command. 

When you have tasks that are dependent on other tasks, you must resume the dependent tasks BEFORE the triggering tasks. Resume LOAD_LOGS_ENHANCED first, then resume GET_NEW_FILES. 

FYI: The first task in the chain is called the Root Task. In our case, GET_NEW_FILES is our Root Task. 
*/
alter task AGS_GAME_AUDIENCE.RAW.LOAD_LOGS_ENHANCED resume;
alter task AGS_GAME_AUDIENCE.RAW.GET_NEW_FILES resume;

/*
NOTE: These graphs are sometimes called DAGS (Directed Acyclic Graphs) instead of just "Graphs". Look at how fancy you are now that you know that!

🦗 Patience Grasshopper
Now that you have resumed your tasks, the root is scheduled, but hasn't yet run. When will it run? Check your Task History. 

Once it completes it's run, it will trigger the next task. Only AFTER that task has completed will the DORA check on the next page pass. So watch your tasks succeed before proceeding to the DORA check on the next page. 
*/

execute task AGS_GAME_AUDIENCE.RAW.GET_NEW_FILES;


use util_db.public;
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from
(
SELECT
'DNGW05' as step
 ,(
   select max(tally) from (
       select CASE WHEN SCHEDULED_FROM = 'SCHEDULE' 
                         and STATE= 'SUCCEEDED' 
              THEN 1 ELSE 0 END as tally 
   from table(ags_game_audience.information_schema.task_history (task_name=>'GET_NEW_FILES')))
  ) as actual
 ,1 as expected
 ,'Task succeeds from schedule' as description
 ); 

 /*
 🎯 Allow Your Tasks to Succeed, Then Suspend The Root
Once you've seen the new versions of the tasks succeed and passed the DORA check above, you can SUSPEND the root task.  

If you are stopping your learning for today, suspend your root task until you need it again.

REMEMBER: It is your responsibility to protect your free trial credits. If you squander your credits and run out before completing the badge requirements, you will have to start over with a new trial account, or enter a credit card to finish the workshop.  This is NOT the same as exceeding the quota on a resource monitor. Resource monitors are easy to reset and fully in your control. 
*/

select max(tally) from (
    select 
        CASE WHEN SCHEDULED_FROM = 'SCHEDULE' and STATE= 'SUCCEEDED' THEN 1 ELSE 0 END as tally 
        ,SCHEDULED_FROM
        ,STATE
        ,scheduled_time
        ,*
    from table(ags_game_audience.information_schema.task_history (task_name=>'GET_NEW_FILES'))
)
;