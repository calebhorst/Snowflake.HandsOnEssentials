/*
📓  The Power of Hub & Spoke Pub/Sub Systems
Now that Kishore has set up an SNS Topic and a Bucket event notification (okay, it was really the Snowflake Ed Services team that set it up, but let's pretend), you and other workshop learners can just run the CREATE PIPE step!!

Each of you will run the same CREATE PIPE Statement, with the same SNS Topic value, and Voila! you will have a working Snowpipe!

Go Ahead! Run the code below!!
*/

-- 🥋 Create Your Snowpipe!
USE ROLE sysadmin;
USE ags_game_audience.raw;

TRUNCATE TABLE ed_pipeline_logs;

CREATE OR REPLACE PIPE pipe_get_new_files
AUTO_INGEST=TRUE
AWS_SNS_TOPIC='arn:aws:sns:us-west-2:321463406630:dngw_topic'
AS 
COPY INTO ed_pipeline_logs
FROM (
  SELECT 
    metadata$filename AS log_file_name,
    metadata$file_row_number AS log_file_row_id,
    CURRENT_TIMESTAMP(0) AS load_ltz,
    GET($1,'datetime_iso8601')::TIMESTAMP_NTZ AS datetime_iso8601,
    GET($1,'user_event')::TEXT AS user_event,
    GET($1,'user_login')::TEXT AS user_login,
    GET($1,'ip_address')::TEXT AS ip_address    
  FROM @AGS_GAME_AUDIENCE.RAW.UNI_KISHORE_PIPELINE
)
FILE_FORMAT = (FORMAT_NAME = ff_json_logs);

/*
📓  Our Event-Driven Pipeline Progress
We've got one more step to complete our Event-Driven Pipeline. We need to update our LOAD_LOGS_ENHANCED task so that it loads from the ED_PIPELINE_LOGS table instead of the PIPELINE_LOGS table. To finalize the Event-Driven pipeline, we need to edit the existing LOAD_LOGS_ENHANCED task we set up earlier and RESUME it! 

🎯 Update the LOAD_LOGS_ENHANCED Task
Your old pipeline had two tasks. Your new pipeline uses one task and one Snowpipe. The task that continues to be used will need to be edited for the new configuration. 

Begin by TRUNCATING your LOGS_ENHANCED table so we can check the CURRENT pipeline and not get confused by our previous pipeline's results. (If you want to create a clone of it first, just in case, go ahead and do that. You could call it LOGS_ENHANCED_BACKUP.
Edit the LOAD_LOGS_ENHANCED Task so it loads from ED_PIPELINE_LOGS instead of PL_LOGS . If the task is running, you'll need to suspend it. 
Now that there is no ROOT task, you can't use the ROOT task to trigger the LOAD_LOGS_ENHANCED. You need to set it back to being a task scheduled every 5 minutes. 
Resume the task.  (Remember to SUSPEND THE TASK before you stop for the day and turn it back on when you resume next time)
NOTE: You now have both one PIPE and one TASK running! Keep this in mind and if your Resource Monitor blocks you, go in and edit it to allow for 2 credit hours today, or even 3!

🪄 Tips to Help You With the Challenge Lab Above
Copy/Paste the Merge Task definition into a Worksheet.
Edit the "r" SELECT definition to what you think it should be. Run it alone by highlighting it before clicking run. 

Next, you can highlight from the word MERGE, to the end and run the MERGE. It's okay if it doesn't load any rows - as long as it doesn't give you an error, you should be fine. Simply run the full statement to replace the Task with the new version, then go in and resume the task. (remember to edit it so it runs every 5 minutes instead of as a triggered task). 
*/
TRUNCATE TABLE enhanced.logs_enhanced;

ALTER TASK ags_game_audience.raw.get_new_files SUSPEND;
ALTER TASK ags_game_audience.raw.load_logs_enhanced SUSPEND;


CREATE OR REPLACE TASK ags_game_audience.raw.load_logs_enhanced
  warehouse='COMPUTE_WH'
  SCHEDULE='5 minute'
AS
  MERGE INTO enhanced.logs_enhanced ASe
  USING (
    SELECT
      logs.ip_address,
      logs.user_login AS gamer_name,
      logs.user_event AS game_event_name,
      logs.datetime_iso8601 AS game_event_utc,
      city,
      region,
      country,
      timezone AS gamer_ltz_name,
      CONVERT_TIMEZONE( 'UTC',timezone,logs.datetime_iso8601) AS game_event_ltz,
      DAYNAME(game_event_ltz) AS dow_name,
      tod_name
    FROM ags_game_audience.raw.ed_pipeline_logs ASlogs
    INNER JOIN ipinfo_geoloc.demo.location ASloc
      ON ipinfo_geoloc.public.TO_JOIN_KEY(logs.ip_address) = loc.join_key
      AND ipinfo_geoloc.public.TO_INT(logs.ip_address) BETWEEN start_ip_int AND end_ip_int
    INNER JOIN ags_game_audience.raw.time_of_day_lu AStod ON HOUR(game_event_ltz) = tod.hour
  ) ASr
    ON r.gamer_name = e.gamer_name
    AND r.game_event_utc = e.game_event_utc
    AND r.game_event_name = e.game_event_name
  WHEN NOT MATCHED THEN
    INSERT (
      ip_address,
      gamer_name,
      game_event_name,
      game_event_utc,
      city,
      region,
      country,
      gamer_ltz_name,
      game_event_ltz,
      dow_name,
      tod_name
    )
    VALUES (
      ip_address,
      gamer_name,
      game_event_name,
      game_event_utc,
      city,
      region,
      country,
      gamer_ltz_name,
      game_event_ltz,
      dow_name,
      tod_name
    )
;

ALTER TASK ags_game_audience.raw.load_logs_enhanced RESUME;

/*
By viewing our COPY HISTORY, we can confirm that our Snowpipe is being triggered and is processing the new files to load the new rows of data. 

There's also a TASK HISTORY page in the same area. Check that out, as well!!

If it seems like your Snowpipe is not active you can run some commands to check things and get them going again.
*/
USE ROLE accountadmin;
SELECT 
  file_name,
  error_count,
  status,
  last_load_time 
FROM snowflake.account_usage.copy_history
ORDER BY last_load_time DESC
LIMIT 10;

--Use this command if your Snowpipe seems like it is stalled out:

ALTER PIPE ags_game_audience.raw.pipe_get_new_files REFRESH;

--Use this command if you want to check that your pipe is running:
SELECT PARSE_JSON(system$pipe_status( 'ags_game_audience.raw.PIPE_GET_NEW_FILES' ));
/*
📓 Fully Event-Driven?
You probably noticed that our new Pipe did not make our entire pipeline "event driven."

STEP 1: Time-driven. We still have a time-based process writing files to the bucket. This is because it's fake. In the real world, gamers would be logging in to Agnie's game at different rates and the logs would be arriving in a more organic way. So making this first step time-driven is just a necessary compromise for this workshop. 

STEP 2: Event-driven. Yay us!

STEP 3: Time-driven. Aww, man. Sorry.  But the good news is that you now have hands-on experience with two of the most important pipeline devices in Snowflake: tasks and pipes. Though, there is something a little more "responsive" we can do in step 3...

In order to make step 3 more responsive, we can add something called a STREAM.

STREAMS can get VERY sophisticated and complex. The STREAM you are about to create will be very basic. To effectively use STREAMS in your work, you will want to get more advanced Snowflake training or read up and experiment on your own.  For now, we include STREAMS so that you will know they exist and have the most basic understanding of how they work.  Below is a diagram of the STREAM we will add to our latest pipeline. 

The diagram above shows that STREAM will not replace that last task and it will not make it event-driven, but it will make the pipeline more efficient. It will do this by allowing us to use a technique called "Change Data Capture" which is why the diagram is labeled with "CDC."

Let's start by adding the STREAM. 
*/

-- 🥋 Create a Stream
--create a stream that will keep track of changes to the table
USE ROLE sysadmin;
CREATE OR REPLACE STREAM ags_game_audience.raw.ed_cdc_stream 
ON TABLE ags_game_audience.raw.ed_pipeline_logs;

--look at the stream you created
SHOW STREAMS;

--check to see if any changes are pending (expect FALSE the first time you run it)
--after the Snowpipe loads a new file, expect to see TRUE
SELECT system$stream_has_data('ed_cdc_stream');

/*
🎯 Suspend the LOAD_LOGS_ENHANCED Task
The LOAD_LOGS_ENHANCED task we've been using looks at EVERY row and checks to see if it has been added to the LOGS_ENHANCED table. Imagine how wasteful that would be if the task was running for years. It would be wasting a lot of compute power! 

We'll be creating a new MERGE task that is more efficient, so SUSPEND the LOAD_LOGS_ENHANCED task right now -- we won't need it again.
*/
ALTER TASK raw.load_logs_enhanced SUSPEND;

/*
📓 Streams Can Be VERY Complex - Ours is Simple
In the simplest use, streams appear very simple. They are just a running list of things that have changed in your table or view. But in production use, to use streams effectively, you will need to understand offsets, data retention periods, staleness, and stream types. We're not covering those in this workshop.

We're only covering the most basic use of a stream, one that will only handle record inserts and will not be guaranteed to track and process every change. 
*/

USE ROLE accountadmin;
SELECT *
FROM snowflake.account_usage.task_history
ORDER BY completed_time DESC
LIMIT 100;

SHOW TASKS;


-- 🥋 View Our Stream Data
--query the stream
SELECT * 
FROM ags_game_audience.raw.ed_cdc_stream; 

--check to see if any changes are pending
SELECT system$stream_has_data('ed_cdc_stream');

--if your stream remains empty for more than 10 minutes, make sure your PIPE is running
SELECT SYSTEM$PIPE_STATUS('PIPE_GET_NEW_FILES');

--if you need to pause or unpause your pipe
--alter pipe PIPE_GET_NEW_FILES set pipe_execution_paused = true;
--alter pipe PIPE_GET_NEW_FILES set pipe_execution_paused = false;

/*
📓 Processing Our Simple Stream
We'll use the records in our STREAM to insert new records into the LOGS_ENHANCED table. This is more sophisticated than using a MERGE that looks at EVERY row in our source table. 
*/

-- 🥋 Process the Rows from the Stream
--make a note of how many rows are in the stream
SELECT * 
FROM ags_game_audience.raw.ed_cdc_stream; 

 
--process the stream by using the rows in a merge 
MERGE INTO ags_game_audience.enhanced.logs_enhanced ASe
USING (
  SELECT
    cdc.ip_address,
    cdc.user_login AS gamer_name,
    cdc.user_event AS game_event_name,
    cdc.datetime_iso8601 AS game_event_utc,
    city,
    region,
    country,
    timezone AS gamer_ltz_name,
    CONVERT_TIMEZONE( 'UTC',timezone,cdc.datetime_iso8601) AS game_event_ltz,
    DAYNAME(game_event_ltz) AS dow_name,
    tod_name
  FROM ags_game_audience.raw.ed_cdc_stream AScdc
  INNER JOIN ipinfo_geoloc.demo.location ASloc 
    ON ipinfo_geoloc.public.TO_JOIN_KEY(cdc.ip_address) = loc.join_key
    AND ipinfo_geoloc.public.TO_INT(cdc.ip_address) 
    BETWEEN start_ip_int AND end_ip_int
  INNER JOIN ags_game_audience.raw.time_of_day_lu AStod
    ON HOUR(game_event_ltz) = tod.hour
) ASr
  ON r.gamer_name = e.gamer_name
  AND r.game_event_utc = e.game_event_utc
  AND r.game_event_name = e.game_event_name 
WHEN NOT MATCHED THEN 
  INSERT (
    ip_address, gamer_name, game_event_name,
    game_event_utc, city, region,
    country, gamer_ltz_name, game_event_ltz,
    dow_name, tod_name
  )
  VALUES
  (
    ip_address, gamer_name, game_event_name,
    game_event_utc, city, region,
    country, gamer_ltz_name, game_event_ltz,
    dow_name, tod_name
  );
 
--Did all the rows from the stream disappear? 
SELECT * 
FROM ags_game_audience.raw.ed_cdc_stream; 

/*
📓 What Happens if the Merge Fails?
This is one of the reasons Streams can be very complex. Since the information disappears as you process it, when using a stream in production systems, you will likely want to have more protection in place to make sure you don't lose information. For example, our old task that looks at EVERY row EVERY time could be run just once every 24 hours so that it could pick up anything missed by the task that processes the stream. 

In any event, this stream and stream processing routine is showing you only the most simple example. However, even though it IS very simple, we hope you can also see how powerful streams can be in systems that need Change Data Capture pipelines. 

📓 The Final Task in Our Pipeline - Ripe For Improvement
With the PIPE and STREAM in place, we just need a task at the end that pulls new data from the STREAM, instead of from the RAW data table. We can use the MERGE statement we just tested.
*/

-- 🥋 Create a CDC-Fueled, Time-Driven Task
--Create a new task that uses the MERGE you just tested
CREATE OR REPLACE TASK ags_game_audience.raw.cdc_load_logs_enhanced
  USER_TASK_MANAGED_INITIAL_WAREHOUSE_SIZE='XSMALL'
  SCHEDULE = '5 minutes'
AS 
  MERGE INTO ags_game_audience.enhanced.logs_enhanced ASe
  USING (
    SELECT
      cdc.ip_address,
      cdc.user_login AS gamer_name,
      cdc.user_event AS game_event_name,
      cdc.datetime_iso8601 AS game_event_utc,
      city,
      region,
      country,
      timezone AS gamer_ltz_name,
      CONVERT_TIMEZONE( 'UTC',timezone,cdc.datetime_iso8601) AS game_event_ltz,
      DAYNAME(game_event_ltz) AS dow_name,
      tod_name
    FROM ags_game_audience.raw.ed_cdc_stream AScdc
    INNER JOIN ipinfo_geoloc.demo.location ASloc 
      ON ipinfo_geoloc.public.TO_JOIN_KEY(cdc.ip_address) = loc.join_key
      AND ipinfo_geoloc.public.TO_INT(cdc.ip_address) 
      BETWEEN start_ip_int AND end_ip_int
    INNER JOIN ags_game_audience.raw.time_of_day_lu AStod
      ON HOUR(game_event_ltz) = tod.hour
  ) ASr
    ON r.gamer_name = e.gamer_name
    AND r.game_event_utc = e.game_event_utc
    AND r.game_event_name = e.game_event_name 
  WHEN NOT MATCHED THEN 
    INSERT (
      ip_address, gamer_name, game_event_name,
      game_event_utc, city, region,
      country, gamer_ltz_name, game_event_ltz,
      dow_name, tod_name
    )
    VALUES
    (
      ip_address, gamer_name, game_event_name,
      game_event_utc, city, region,
      country, gamer_ltz_name, game_event_ltz,
      dow_name, tod_name
    );
        
--Resume the task so it is running
ALTER TASK ags_game_audience.raw.cdc_load_logs_enhanced RESUME;

/*
📓 A Final Improvement!
Let's add one more piece of Data Engineering sophistication to the Pipeline. It won't improve our load costs, because our files are going to load every 5 minutes by design, but if you have a truly event-driven pipeline on the front end, this last enhancement can make a difference in the last step of your pipeline. 

We're going to add a WHEN clause to the TASK that checks the STREAM. It will still try to run every 5 minutes, but if nothing has changed, it won't continue running. 

🎯 Add A Stream Dependency to the Task Schedule
Add STREAM dependency logic to the TASK header and replace the task. 
*/
CREATE OR REPLACE TASK ags_game_audience.raw.cdc_load_logs_enhanced
  USER_TASK_MANAGED_INITIAL_WAREHOUSE_SIZE='XSMALL'
  SCHEDULE = '5 minutes'
WHEN
  system$stream_has_data('ed_cdc_stream')
AS 
  MERGE INTO ags_game_audience.enhanced.logs_enhanced ASe
  USING (
    SELECT
      cdc.ip_address,
      cdc.user_login AS gamer_name,
      cdc.user_event AS game_event_name,
      cdc.datetime_iso8601 AS game_event_utc,
      city,
      region,
      country,
      timezone AS gamer_ltz_name,
      CONVERT_TIMEZONE( 'UTC',timezone,cdc.datetime_iso8601) AS game_event_ltz,
      DAYNAME(game_event_ltz) AS dow_name,
      tod_name
    FROM ags_game_audience.raw.ed_cdc_stream AScdc
    INNER JOIN ipinfo_geoloc.demo.location ASloc 
      ON ipinfo_geoloc.public.TO_JOIN_KEY(cdc.ip_address) = loc.join_key
      AND ipinfo_geoloc.public.TO_INT(cdc.ip_address) 
      BETWEEN start_ip_int AND end_ip_int
    INNER JOIN ags_game_audience.raw.time_of_day_lu AStod
      ON HOUR(game_event_ltz) = tod.hour
  ) ASr
    ON r.gamer_name = e.gamer_name
    AND r.game_event_utc = e.game_event_utc
    AND r.game_event_name = e.game_event_name 
  WHEN NOT MATCHED THEN 
    INSERT (
      ip_address, gamer_name, game_event_name,
      game_event_utc, city, region,
      country, gamer_ltz_name, game_event_ltz,
      dow_name, tod_name
    )
    VALUES
    (
      ip_address, gamer_name, game_event_name,
      game_event_utc, city, region,
      country, gamer_ltz_name, game_event_ltz,
      dow_name, tod_name
    );
        
--Resume the task so it is running
ALTER TASK ags_game_audience.raw.cdc_load_logs_enhanced RESUME;

/*
📓 Confirming Data is Flowing 
The data makes two stops in your account.  The first table the data lands in is ED_PIPELINE_LOGS. 
The data arrives there because of the Snowpipe named GET_NEW_FILES. 

We can see that our table has 2.3K records in it right now (your row count will depend on the time of day you are doing this) and that it is loading every 5 minutes as the files arrive in the bucket. 

If we refresh this page, the number of rows should climb by 10 every five minutes.

The second stop for the data is the AGS_GAME_AUDIENCE.ENHANCED.LOGS_ENHANCED table. 

Use all the tools available to you to check that both the pipe and task are working to move data all the way from the stage to the enhanced table. Remember that there should be 10 records in every new file, but that not all 10 rows will make it to the Enhanced table, because of the join to the IPInfo share table. 
*/

SELECT *
FROM ags_game_audience.raw.ed_pipeline_logs
;

SELECT *
FROM ags_game_audience.enhanced.logs_enhanced
;


USE util_db.public;
SELECT GRADER(step, (actual = expected), actual, expected, description) AS graded_results FROM
  (
    SELECT
      'DNGW06' AS step,
      (
        SELECT CASE WHEN pipe_status:executionState::TEXT = 'RUNNING' THEN 1 ELSE 0 END 
        FROM(
          SELECT PARSE_JSON(system$pipe_status( 'ags_game_audience.raw.PIPE_GET_NEW_FILES' )) AS pipe_status
        )
      ) AS actual,
      1 AS expected,
      'Pipe exists and is RUNNING' AS description
  ); 

 